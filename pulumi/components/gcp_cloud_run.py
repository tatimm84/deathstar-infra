# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

"""
GCP Cloud Run component.
References:
https://www.pulumi.com/registry/packages/gcp/api-docs/cloudrunv2/
"""

from __future__ import annotations

import json
import os
from typing import Any

import pulumi_gcp as gcp
from utils.json_reader import (
    calculate_directory_hash,
    read_json_files,
    render_content,
    slugify,
)
from utils.schemas import gcp_cloud_run_job, gcp_cloud_run_service
from utils.validations import validate_entries
from variables import (
    GCP_PROJECT,
    GCP_REGION,
    SRC_CODE_PATH,
    SRC_INFRA_PATH,
)

import pulumi


def _collect_pipeline_and_config_envs() -> dict[str, Any]:
    """
    Coleta variáveis do pipeline (via os.environ) e do pulumi config para
    injetar nos containers do Cloud Run.
    - Pega todas as variáveis com prefixo PULUMI_VAR_ do ambiente e remove o prefixo.
    - Pega algumas chaves explícitas do 'pulumi config'.
    - Pega opcionalmente 'ci:TOKEN_SA' como segredo (Output[str]).
    """
    envs: dict[str, Any] = {}

    # 1) Variáveis do pipeline expostas como env.
    # Ex.: PULUMI_VAR_ENVIRONMENT -> ENVIRONMENT
    for k, v in os.environ.items():
        if k.startswith("PULUMI_VAR_") and v:
            envs[k.replace("PULUMI_VAR_", "", 1)] = v

    # 2) Algumas chaves do pulumi config que fazem sentido no runtime
    cfg = pulumi.Config()
    for key in [
        "ENVIRONMENT",
        "PROJECT_NUMBER",
        "UID_NOW",
        "AZURE_DEVOPS_REPO",
        "SRC_INFRA_PATH",
        "RUNNING_SERVICE_ACCOUNT",
    ]:
        val = cfg.get(key)
        if val is not None:
            envs[key] = val

    # 3) Opcional: segredo curto do pipeline (use com cautela)
    token_sa = cfg.get_secret("ci:TOKEN_SA")
    if token_sa is not None:
        # Se quiser desabilitar a exposição, comente a linha abaixo
        envs["TOKEN_SA"] = token_sa

    return envs


def _merge_envs_into_containers(
    containers: list[dict[str, Any]] | None,
    extra_env_map: dict[str, Any],
    override: bool = True,
) -> list[dict[str, Any]]:
    """
    Merges additional environment variables into all containers in the template.
    - override=True: pipeline/config variables overwrite those in the JSON.
    - override=False: JSON variables have precedence.
    """
    containers = containers or []
    merged_containers: list[dict[str, Any]] = []

    for container in containers:
        # Ensure mutable dict
        c_dict = dict(container) if not isinstance(container, dict) else container

        # JSON configs may use the Terraform key "env" or the Pulumi key "envs".
        # Read both to avoid silently ignoring one, then normalise to "envs" and
        # delete "env" so Pulumi never sees both pointing at the same TF attribute.
        existing_envs = c_dict.get("envs") or c_dict.get("env") or []
        env_map: dict[str, dict[str, Any]] = {}

        # Normalize existing envs from JSON
        for item in existing_envs:
            if isinstance(item, dict) and item.get("name"):
                env_map[item["name"]] = item

        # Remove the Terraform-style key so the dict only ever has "envs"
        c_dict.pop("env", None)

        # Merge with pipeline/config envs
        for name, value in extra_env_map.items():
            if name in env_map and not override:
                continue
            env_map[name] = {"name": name, "value": value}

        # Reassign envs
        c_dict["envs"] = list(env_map.values())
        merged_containers.append(c_dict)

    return merged_containers


def _clean_job_containers(containers: list[dict[str, Any]]) -> None:
    """Removes unsupported features from job containers (like cpu_idle)."""
    for c in containers:
        resources = c.get("resources")
        if not resources:
            continue

        resources.pop("cpu_idle", None)
        limits = resources.get("limits")
        if isinstance(limits, dict):
            limits.pop("cpu_idle", None)


def _process_resource_containers(
    content: dict[str, Any],
    cloud_run_type: str,
    pipeline_envs: dict[str, Any],
) -> None:
    """Handles container structure and env merging based on resource type."""
    template_block = content.get("template") or {}

    if cloud_run_type == "service":
        containers = template_block.get("containers") or []
        template_block["containers"] = _merge_envs_into_containers(
            containers, pipeline_envs, override=True
        )
    elif cloud_run_type == "job":
        # Jobs have an extra layer of nesting for the execution template
        template_block.pop("containers", None)  # Clean up any misplaced keys
        inner_template = template_block.get("template") or {}
        containers = inner_template.get("containers") or []

        _clean_job_containers(containers)

        inner_template["containers"] = _merge_envs_into_containers(
            containers, pipeline_envs, override=True
        )
        template_block["template"] = inner_template

    content["template"] = template_block


def _preprocess(
    files: list[dict[str, Any]], template_vars: dict[str, str]
) -> list[dict[str, Any]]:
    processed_files: list[dict[str, Any]] = []
    for item in files:
        content = item.get("content", {})
        image_path = content.get("image_path", f"{SRC_CODE_PATH}/{item['file_name']}")
        final_vars = dict(template_vars)

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
                pulumi.log.error(f"Failed to re-render {item['file_name']}: {e}")
        processed_files.append(
            {
                "source": item["source"],
                "file_name": item["file_name"],
                "path_type": item["path_type"],
                "content": content,
                "sha1": dir_hash,
            }
        )
    return processed_files


def create_cloud_run(
    template_vars: dict[str, str],
    opts: pulumi.ResourceOptions | None = None,
    json_files: list[dict[str, Any]] | None = None,
    extra_json_files: list[dict[str, Any]] | None = None,
) -> dict[str, Any]:
    """
    Create Cloud Run services and jobs based on JSON configuration files.
    Files should be at root: infra/gcp/auto/cloud_run/<any>.json

    Args:
        template_vars: Template variables for substitution
        opts: Pulumi resource options (opcional)
        json_files: (opcional) Loaded JSON files list for local tests.
            If None, use read_json_files(...) from SRC_INFRA_PATH.
        extra_json_files: Additional configurations to merge.

    Returns:
        Dictionary with created Cloud Run resources {"services": [...], "jobs": [...]}
    """
    # 1) Read JSONs (with variable substitution)
    if json_files is None:
        files = read_json_files(
            source_path=f"{SRC_INFRA_PATH}/gcp/auto/cloud_run/",
            files_regex="**",
            template_vars=template_vars,
        )
    else:
        files = list(json_files)

    if extra_json_files:
        files.extend(extra_json_files)

    # 2) Pre-process: calculate __sha1__ and re-render content if raw content is
    # available
    processed_files = _preprocess(files, template_vars)
    # Coleta envs vindas do pipeline/config uma única vez
    pipeline_envs = _collect_pipeline_and_config_envs()

    # 3) Validate files and create resources
    services: list[Any] = []
    jobs: list[Any] = []
    for entry in processed_files:
        content = entry.get("content", {}) or {}
        cloud_run_type = content.get("cloud_run_type", "service")
        location = content.get("location", GCP_REGION)

        _process_resource_containers(content, cloud_run_type, pipeline_envs)

        if cloud_run_type == "service":
            validate_entries(entries=[entry], schema=gcp_cloud_run_service)
            service = gcp.cloudrunv2.Service(
                resource_name=f"cloud_run_service_{slugify(entry['file_name'])}",
                annotations=content.get("annotations"),
                client=content.get("client"),
                client_version=content.get("client_version"),
                custom_audiences=content.get("custom_audiences"),
                default_uri_disabled=content.get("default_uri_disabled"),
                description=content.get("description"),
                ingress=content.get("ingress"),
                labels=content.get("labels"),
                launch_stage=content.get("launch_stage"),
                location=location,
                name=entry["file_name"],
                project=GCP_PROJECT,
                template=content.get("template"),
                traffics=content.get("traffics"),
                opts=opts,
            )
            services.append(service)

        elif cloud_run_type == "job":
            validate_entries(entries=[entry], schema=gcp_cloud_run_job)
            job = gcp.cloudrunv2.Job(
                resource_name=f"cloud_run_job_{slugify(entry['file_name'])}",
                annotations=content.get("annotations"),
                client=content.get("client"),
                client_version=content.get("client_version"),
                labels=content.get("labels"),
                launch_stage=content.get("launch_stage"),
                location=location,
                name=entry["file_name"],
                project=GCP_PROJECT,
                start_execution_token=content.get("start_execution_token"),
                run_execution_token=content.get("run_execution_token"),
                template=content.get("template"),
                opts=opts,
            )
            jobs.append(job)

        else:
            pulumi.log.warn(
                f"{entry['file_name']}: Unknown cloud_run_type '{cloud_run_type}'."
                " Ignoring."
            )

    return {"services": services, "jobs": jobs}
