# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

"""
GCP Artifact Registry component.
References:
https://www.pulumi.com/registry/packages/gcp/api-docs/artifactregistry/
https://www.pulumi.com/registry/packages/docker/api-docs/image/
"""

from __future__ import annotations

import json
import os
from typing import Any, cast

import pulumi_docker as docker
import pulumi_gcp as gcp
from utils.json_reader import (
    calculate_directory_hash,
    read_json_files,
    render_content,
    slugify,
)
from utils.schemas import gcp_artifact_registry_image, gcp_artifact_registry_repository
from utils.validations import validate_entries
from variables import ENVIRONMENT, GCP_PROJECT, GCP_REGION, SRC_INFRA_PATH

import pulumi


def _preprocess(files, template_vars: dict[str, str]) -> list[dict[str, Any]]:
    """
    Calculate __sha1__ if image_path and
    re-render content if raw content is available.
    """
    processed_files: list[dict[str, Any]] = []

    for item in files:
        content = item.get("content", {}) or {}
        image_path = content.get("image_path")
        final_vars = dict(template_vars)
        if image_path:
            try:
                dir_hash = calculate_directory_hash(image_path)
                final_vars["__sha1__"] = dir_hash
            except Exception as e:
                pulumi.log.error(f"Failed to calculate SHA1 of {image_path}: {e}")

        if item.get("content_raw"):
            try:
                rendered = render_content(item["content_raw"], final_vars)
                content = json.loads(rendered)
            except Exception as e:
                pulumi.log.error(f"Failed to re-render {item['source']}: {e}")
        processed_files.append(
            {
                "source": item["source"],
                "file_name": item["file_name"],
                "path_type": item["path_type"],
                "content": content,
            }
        )

    return processed_files


def _infer_repo_id_from_entry(entry: dict[str, Any]) -> str | None:
    """
    Try to infer repository_id:
      1) from content (if exists),
      2) from filename (artifact_registry/<repo>.json),
      3) from foldername (artifact_registry/<repo>/<file>.json).
    """
    repository_id = None

    # 1) Conteúdo
    content = entry.get("content", {}) or {}
    path_type = entry.get("path_type", "")
    if content.get("repository_id"):
        return cast(str | None, content["repository_id"])

    # 2) Path
    if not repository_id:
        # entry["source"] exemplo: artifact_registry/repo/file...
        # Assumindo separador /
        source = entry["source"].replace("\\", "/").replace("__env__", ENVIRONMENT)
        parts = source.split("/")
        repository_id = parts[1]

        # arquivo root: artifact_registry/<repo>.json
        if path_type == "root":
            repository_id = repository_id.replace(".json", "")
    return cast(str | None, repository_id)


def create_artifact_registry(
    template_vars: dict[str, str],
    opts: pulumi.ResourceOptions | None = None,
    json_files: list[dict[str, Any]] | None = None,
    extra_json_files: list[dict[str, Any]] | None = None,
) -> dict[str, Any]:
    """
    Create Artifact Registry repositories and Docker images (build/push)
    based on JSON configuration files.
    Wanted:
      - Repositories files at root: infra/gcp/auto/artifact_registry/<repo>.json
      - Images files inside repository folder:
      infra/gcp/auto/artifact_registry/<repo>/<any>.json

    Args:
        template_vars: Template variables for substitution
        opts: Pulumi resource options (opcional)
        json_files: (opcional) Loaded JSON files list for local tests.
            If None, use read_json_files(...) from SRC_INFRA_PATH.
        extra_json_files: Additional configurations to merge.

    Returns:
        Dictionary of created Artifact Registry resources
    """
    # 1) Read JSONs (with variable substitution)
    if json_files is None:
        files = read_json_files(
            source_path=f"{SRC_INFRA_PATH}/gcp/auto/artifact_registry/",
            files_regex="**",
            template_vars=template_vars,
        )
    else:
        files = list(json_files)

    if extra_json_files:
        files.extend(extra_json_files)

    # 2) Pre-process files
    processed_files = _preprocess(files, template_vars)

    # 3) Validate files and create resources
    repositories: list[Any] = []
    images: list[Any] = []
    created_repos_map: dict[str, Any] = {}

    # -------- Repositories --------
    for entry in processed_files:
        if entry["path_type"] != "root":
            continue

        content = entry.get("content", {}) or {}
        repo_id = _infer_repo_id_from_entry(entry)
        if not repo_id:
            pulumi.log.warn(
                f"Not possible to infer repository_id to {entry['source']}. "
                "Ignoring repository creation."
            )
            continue

        # 3.1) Validate files
        validate_entries(entries=[entry], schema=gcp_artifact_registry_repository)

        # 3.2) Create resources
        repo = gcp.artifactregistry.Repository(
            resource_name=f"ar_repo_{slugify(entry['file_name'])}",
            cleanup_policy_dry_run=content.get("cleanup_policy_dry_run"),
            description=content.get("description"),
            format=content.get("format", "DOCKER"),
            kms_key_name=content.get("kms_key_name"),
            location=content.get("location", GCP_REGION),
            labels=content.get("labels"),
            mode=content.get("mode"),
            project=GCP_PROJECT,
            repository_id=repo_id,
            opts=opts,
        )
        repositories.append(repo)
        created_repos_map[repo_id] = repo

    # -------- Images --------
    for entry in processed_files:
        if entry["path_type"] != "subdir":
            continue

        content = entry.get("content", {}) or {}
        repo_id = _infer_repo_id_from_entry(entry)
        if not repo_id:
            pulumi.log.warn(
                f"Not possible to infer repository_id to {entry['source']}. "
                "Ignoring image creation."
            )
            continue

        # 3.1) Validate files
        validate_entries(entries=[entry], schema=gcp_artifact_registry_image)

        # 3.2) Create resources (build/push images)
        location = content.get("location", GCP_REGION)
        image_name_base = os.path.splitext(os.path.basename(entry["source"]))[0]
        build = content.get("build", {}) or {}
        context_abs = os.path.abspath(os.path.normpath(content.get("image_path", ".")))
        build["context"] = context_abs
        build["dockerfile"] = os.path.abspath(os.path.join(context_abs, "Dockerfile"))

        # Build Args
        build_args = build.get("args", {})
        build_args["TOKEN_SA"] = pulumi.Config("ci").require_secret("TOKEN_SA")

        # Set default image path if not present (for hashing)
        build["args"] = build_args
        tags = build.get("tag", ["latest"])
        parent_repo = created_repos_map.get(repo_id)

        for tag in tags:
            prefix = f"{location}-docker.pkg.dev/{GCP_PROJECT}"
            image_full_name = f"{prefix}/{repo_id}/{image_name_base}:{tag}"

            image = docker.Image(
                resource_name=(
                    f"docker_image_{slugify(entry['file_name'])}_"
                    f"{image_name_base}_{tag}"
                ),
                image_name=image_full_name,
                # docker.DockerBuildArgs()
                build=cast(Any, build),
                # docker.RegistryArgs()
                registry=docker.RegistryArgs(
                    server=f"{location}-docker.pkg.dev",
                    username="oauth2accesstoken",
                    password=pulumi.Config("ci").require_secret("TOKEN_SA"),
                ),
                opts=pulumi.ResourceOptions(
                    parent=parent_repo if parent_repo else None,
                    depends_on=[parent_repo] if parent_repo else [],
                ),
            )
            images.append(image)

    return {"repositories": repositories, "images": images}
