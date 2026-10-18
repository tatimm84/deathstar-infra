# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

"""
GCP Cloud Functions component.
References:
https://www.pulumi.com/registry/packages/gcp/api-docs/cloudfunctions/
https://www.pulumi.com/registry/packages/gcp/api-docs/cloudfunctionsv2/
"""

from __future__ import annotations

import os
from typing import Any, cast

import pulumi_gcp as gcp
from utils.json_reader import read_json_files, slugify
from utils.schemas import gcp_cloud_functions_v1, gcp_cloud_functions_v2
from utils.validations import validate_entries
from variables import (
    GCP_PROJECT,
    GCP_REGION,
    SRC_CODE_PATH,
    SRC_INFRA_PATH,
)

import pulumi
from pulumi import asset


def as_list(x) -> list:
    """Converte None/dict em lista. Se já for lista, retorna igual."""
    if x is None:
        return []
    return x if isinstance(x, list) else [x]


def create_cloud_functions(
    template_vars: dict[str, str],
    opts: pulumi.ResourceOptions | None = None,
    json_files: list[dict[str, Any]] | None = None,
) -> dict[str, Any]:
    """
    Create Cloud Functions based on JSON configuration files.
    Files should be at root: infra/gcp/auto/cloud_functions/<any>.json

    Args:
        template_vars: Template variables for substitution
        opts: Pulumi resource options (opcional)
        json_files: (opcional) Loaded JSON files list for local tests.
            If None, use read_json_files(...) from SRC_INFRA_PATH.

    Returns:
        Dictionary of created Cloud Functions
    """
    # 1) Read JSONs (with variable substitution)
    if json_files is None:
        files = read_json_files(
            source_path=f"{SRC_INFRA_PATH}/gcp/auto/cloud_functions/",
            files_regex="**",
            template_vars=template_vars,
        )
    else:
        files = json_files

    # 2) Validate files and create resources
    functions: list[Any] = []
    for entry in files:
        content = entry.get("content", {}) or {}
        generation = str(content.get("generation", "2"))

        # -------- Gen 1 --------
        if generation == "1":
            # 2.1) Validate files
            validate_entries(entries=[entry], schema=gcp_cloud_functions_v1)

            # 2.2) Create resources
            function = gcp.cloudfunctions.Function(
                resource_name=f"function_{slugify(entry['file_name'])}",
                available_memory_mb=content.get("available_memory_mb"),
                build_environment_variables=content.get("build_environment_variables"),
                build_service_account=content.get("build_service_account"),
                build_worker_pool=content.get("build_worker_pool"),
                description=content.get("description"),
                docker_registry=content.get("docker_registry"),
                docker_repository=content.get("docker_repository"),
                entry_point=content.get("entry_point"),
                environment_variables=content.get("environment_variables"),
                # gcp.cloudfunctions.FunctionEventTriggerArgs()
                event_trigger=content.get("event_trigger"),
                https_trigger_security_level=content.get(
                    "https_trigger_security_level"
                ),
                ingress_settings=content.get("ingress_settings"),
                kms_key_name=content.get("kms_key_name"),
                labels=content.get("labels"),
                max_instances=content.get("max_instances"),
                min_instances=content.get("min_instances"),
                name=entry["file_name"],
                # gcp.cloudfunctions.FunctionOnDeployUpdatePolicyArgs()
                on_deploy_update_policy=content.get("on_deploy_update_policy"),
                project=GCP_PROJECT,
                region=content.get("location", GCP_REGION),
                runtime=content.get("runtime"),
                # list(gcp.cloudfunctions.FunctionSecretEnvironmentVariableArgs())
                secret_environment_variables=content.get(
                    "secret_environment_variables"
                ),
                # list(gcp.cloudfunctions.FunctionSecretVolumeArgs())
                secret_volumes=content.get("secret_volumes"),
                service_account_email=content.get("service_account_email"),
                source_archive_bucket=content.get("source_archive_bucket"),
                source_archive_object=content.get("source_archive_object"),
                # gcp.cloudfunctions.FunctionSourceRepositoryArgs()
                source_repository=content.get("source_repository"),
                timeout=content.get("timeout"),
                trigger_http=content.get("trigger_http"),
                vpc_connector=content.get("vpc_connector"),
                vpc_connector_egress_settings=content.get(
                    "vpc_connector_egress_settings"
                ),
                opts=opts,
            )
            functions.append(function)

        # -------- Gen 2 --------
        elif generation == "2":
            # 2.1) Validate files
            validate_entries(entries=[entry], schema=gcp_cloud_functions_v2)

            # 2.2) Create resources
            build_config = content.get("build_config", {}) or {}
            build_config_source = build_config.get("source", {}) or {}
            build_config_storage_source = (
                build_config_source.get("storage_source", {}) or {}
            )

            # Check for local source code
            object_name = build_config_storage_source.get("object")
            local_source_path = os.path.join(SRC_CODE_PATH, entry["file_name"])

            if os.path.isdir(local_source_path):
                # Zip and upload source code
                bucket_name = build_config_storage_source.get("bucket")
                source_archive = asset.FileArchive(local_source_path)

                bucket_object = gcp.storage.BucketObject(
                    resource_name=f"zip_{slugify(entry['file_name'])}",
                    name=f"{entry['file_name']}.zip",
                    bucket=bucket_name,
                    source=source_archive,
                    opts=opts,
                )
                object_name = bucket_object.name
            build_config["source"]["storage_source"]["object"] = object_name
            build_config["source"]["storage_source"]["generation"] = bucket_object.generation

            function_v2 = gcp.cloudfunctionsv2.Function(
                resource_name=f"function_{slugify(entry['file_name'])}",
                # gcp.cloudfunctionsv2.FunctionBuildConfigArgs()
                build_config=cast(Any, build_config),
                description=content.get("description"),
                # gcp.cloudfunctionsv2.FunctionEventTriggerArgs()
                event_trigger=content.get("event_trigger"),
                kms_key_name=content.get("kms_key_name"),
                labels=content.get("labels"),
                location=content.get("location", GCP_REGION),
                name=entry["file_name"],
                project=GCP_PROJECT,
                # gcp.cloudfunctionsv2.FunctionServiceConfigArgs()
                service_config=content.get("service_config"),
                opts=opts,
            )
            functions.append(function_v2)

    return {"functions": functions}
