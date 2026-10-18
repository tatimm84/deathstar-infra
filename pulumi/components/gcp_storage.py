"""
GCP Storage component.
References:
https://www.pulumi.com/registry/packages/gcp/api-docs/storage/
https://www.pulumi.com/registry/packages/gcp/api-docs/storage/bucket/
https://www.pulumi.com/registry/packages/gcp/api-docs/storage/bucketobject/
"""

from __future__ import annotations

import json
from typing import Any

import pulumi_gcp as gcp
from utils.json_reader import (
    read_json_files,
    read_non_json_files,
    slugify,
)
from utils.schemas import gcp_storage_bucket
from utils.validations import validate_entries
from variables import ENVIRONMENT, GCP_PROJECT, GCP_REGION, SRC_INFRA_PATH

import pulumi


def _infer_bucket_path_from_entry(
    entry: dict[str, Any],
) -> tuple[str | None, str | None]:
    """
    Tenta inferir bucket_id do conteúdo ou do source path.
    Aplica substituição de __env__ -> ENVIRONMENT.

    Lógica do path:
      - cloud_storage/<bucket>.json -> bucket
      - cloud_storage/<bucket>/file -> bucket
      - cloud_storage/<bucket>/subdir/file -> bucket
    """
    bucket_id = None
    path = None

    # 1) Conteúdo
    content = entry.get("content", {}) or {}
    path_type = entry.get("path_type", "")
    if content.get("bucket_id"):
        bucket_id = content["bucket_id"]

    # 2) Path
    if not bucket_id:
        # entry["source"] exemplo: cloud_storage/bucket/file...
        # Assumindo separador /
        source = entry["source"].replace("\\", "/").replace("__env__", ENVIRONMENT)
        parts = source.split("/")
        bucket_id = parts[1]

        # arquivo root: cloud_storage/<bucket>.json
        if path_type == "root":
            bucket_id = bucket_id.replace(".json", "")
        # arquivo subdir: cloud_storage/<bucket>/<any>.json
        else:
            sub_path = "/".join(parts[2:-1])
            path = f"{sub_path}/{entry['file_name_extension']}" if sub_path else entry["file_name_extension"]
    return bucket_id, path


def create_storage(
    template_vars: dict[str, str],
    opts: pulumi.ResourceOptions | None = None,
    json_files: list[dict[str, Any]] | None = None,
    extra_json_files: list[dict[str, Any]] | None = None,
) -> dict[str, Any]:
    """
    Create GCS buckets and objects based on JSON configuration files.
    Wanted:
      - Buckets files at root: infra/gcp/auto/cloud_storage/<bucket>.json
      - Objects inside bucket folder:
      infra/gcp/auto/cloud_storage/<bucket>/<any>.json

    Args:
        template_vars: Template variables for substitution
        opts: Pulumi resource options (opcional)
        json_files: (opcional) Loaded JSON files list for local tests.
            If None, use read_json_files(...) from SRC_INFRA_PATH.
        extra_json_files: Additional configurations to merge.

    Returns:
        List of created Storage resources
    """
    # 1) Read JSONs (with variable substitution)
    files: list[Any] = []
    object_files: list[Any] = []
    bkp_files: list[Any] = []
    if json_files is None:
        # Buckets: apenas arquivos na raiz (files_regex="*")
        files = read_json_files(
            source_path=f"{SRC_INFRA_PATH}/gcp/auto/cloud_storage/",
            files_regex="*",
            template_vars=template_vars,
        )
        # Objects: arquivos em subpastas (recursivo)
        object_files = read_non_json_files(
            source_path=f"{SRC_INFRA_PATH}/gcp/auto/cloud_storage/",
            files_regex="*/**/*",
            template_vars=template_vars,
        ) + read_json_files(
            source_path=f"{SRC_INFRA_PATH}/gcp/auto/cloud_storage/",
            files_regex="*/**/*.json",
            template_vars=template_vars,
        )
        # Backup objects
        bkp_files = read_json_files(
            source_path=f"{SRC_INFRA_PATH}/gcp/auto/cloud_storage_backup/",
            files_regex="**",
            template_vars=template_vars,
        )
    else:
        for file in json_files:
            if file["path_type"] == "root":
                files.append(file)
            else:
                object_files.append(file)

    if extra_json_files:
        for file in extra_json_files:
            if file.get("path_type") == "root":
                files.append(file)
            else:
                object_files.append(file)

    # 2) Validate files and create resources
    buckets: list[Any] = []
    objects: list[Any] = []
    for entry in files:
        content = entry.get("content", {}) or {}

        # 2.1) Validate files
        validate_entries(entries=[entry], schema=gcp_storage_bucket)

        # avoid duplicate creation
        bucket_name, _ = _infer_bucket_path_from_entry(entry)
        if bucket_name in buckets:
            continue

        # 2.2) Create resources
        # -------- Bucket --------
        bucket = gcp.storage.Bucket(
            resource_name=f"bucket_{slugify(entry['file_name'])}",
            # gcp.storage.BucketAutoclassArgs()
            autoclass=content.get("autoclass"),
            # list(gcp.storage.BucketCorsArgs())
            cors=content.get("cors"),
            # gcp.storage.BucketCustomPlacementConfigArgs()
            custom_placement_config=content.get("custom_placement_config"),
            default_event_based_hold=content.get("default_event_based_hold"),
            enable_object_retention=content.get("enable_object_retention"),
            # gcp.storage.BucketEncryptionArgs()
            encryption=content.get("encryption"),
            force_destroy=content.get("force_destroy"),
            labels=content.get("labels"),
            # gcp.storage.BucketLifecycleRuleArgs()
            lifecycle_rules=content.get("lifecycle_rules"),
            location=content.get("location", GCP_REGION),
            # gcp.storage.BucketLoggingArgs()
            logging=content.get("logging"),
            name=bucket_name,
            project=GCP_PROJECT,
            public_access_prevention=content.get("public_access_prevention"),
            requester_pays=content.get("requester_pays"),
            # gcp.storage.BucketRetentionPolicyArgs()
            retention_policy=content.get("retention_policy"),
            rpo=content.get("rpo"),
            # gcp.storage.BucketSoftDeletePolicyArgs()
            soft_delete_policy=content.get("soft_delete_policy"),
            storage_class=content.get("storage_class"),
            # gcp.storage.BucketUniformBucketLevelAccessArgs()
            uniform_bucket_level_access=content.get("uniform_bucket_level_access"),
            # gcp.storage.BucketVersioningArgs()
            versioning=content.get("versioning"),
            # gcp.storage.BucketWebsiteArgs()
            website=content.get("website"),
            opts=opts,
        )
        buckets.append(bucket)

    # Create bucket dependency options
    bucket_opts = pulumi.ResourceOptions(
        depends_on=buckets if buckets else None,
        parent=opts.parent if opts else None,
    )

    # -------- Objects --------
    for entry in object_files:
        content_parsed = entry.get("content") or {}
        bucket_name, object_path = _infer_bucket_path_from_entry(entry)

        # Determine content: prefer parsed JSON 'content', fallback to 'content_raw'
        obj_content = content_parsed
        if not obj_content:
            obj_content = entry.get("content_raw")

        if isinstance(obj_content, dict):
            obj_content = json.dumps(obj_content, indent=2)

        obj = gcp.storage.BucketObject(
            resource_name=f"bucket_object_{slugify(entry['file_name'])}",
            bucket=bucket_name,
            content=obj_content,
            name=object_path,
            source=content_parsed.get("source"),
            opts=bucket_opts,
        )
        objects.append(obj)

    # -------- Backup Objects --------
    for entry in bkp_files:
        content = entry.get("content", {}) or {}
        bucket_name, object_path = _infer_bucket_path_from_entry(entry)

        obj = gcp.storage.BucketObject(
            resource_name=f"bucket_object_backup_{slugify(entry['file_name'])}",
            bucket=bucket_name,
            content=content.get("content") if content.get("content") else None,
            name=object_path,
            source=(
                content["source"]
                if content.get("source") and not content.get("content")
                else None
            ),
            opts=bucket_opts,
        )
        objects.append(obj)

    return {
        "buckets": buckets,
        "objects": objects,
    }
