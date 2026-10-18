# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

"""Data Lake Ingestion (DLI) component."""

from __future__ import annotations

from typing import Any

import pulumi_gcp as gcp
from utils.json_reader import read_json_files
from variables import SRC_INFRA_PATH

import pulumi


def create_dli_resources(
    template_vars: dict[str, str],
    opts: pulumi.ResourceOptions | None = None,
) -> dict[str, Any]:
    """
    Create DLI (Data Lake Ingestion) resources.
    Uploads DAGs, pipelines, connectors, secrets, operators, and tasks to GCS.
    """
    # Read DLI configuration files
    pipelines = read_json_files(
        source_path=f"{SRC_INFRA_PATH}/dli/auto/pipelines/",
        files_regex="**/*.json",
        template_vars=template_vars,
    )

    connectors = read_json_files(
        source_path=f"{SRC_INFRA_PATH}/dli/auto/connectors/",
        files_regex="**/*.json",
        template_vars=template_vars,
    )

    secrets = read_json_files(
        source_path=f"{SRC_INFRA_PATH}/dli/auto/secrets/",
        files_regex="**/*.json",
        template_vars=template_vars,
    )

    # Storage objects for DLI artifacts
    pipeline_objects = {}
    connector_objects = {}
    secret_objects = {}

    # Upload pipelines to GCS
    for entry in pipelines:
        obj = gcp.storage.BucketObject(
            f"dli_pipeline_{entry['source']}",
            bucket=template_vars.get("DLI_DATAINTEGRATOR_BUCKET", ""),
            name=(
                f"{template_vars.get('DLI_DATAINTEGRATOR_PATH', '')}/pipelines/"
                f"{entry.get('file_name')}.json"
            ),
            content=pulumi.Output.json_dumps(entry.get("content", {})),
            opts=opts,
        )
        pipeline_objects[entry["source"]] = obj

    # Upload connectors to GCS
    for entry in connectors:
        obj = gcp.storage.BucketObject(
            f"dli_connector_{entry['source']}",
            bucket=template_vars.get("DLI_DATAINTEGRATOR_BUCKET", ""),
            name=(
                f"{template_vars.get('DLI_DATAINTEGRATOR_PATH', '')}/connectors/"
                f"{entry.get('file_name')}.json"
            ),
            content=pulumi.Output.json_dumps(entry.get("content", {})),
            opts=opts,
        )
        connector_objects[entry["source"]] = obj

    # Upload secrets to GCS
    for entry in secrets:
        obj = gcp.storage.BucketObject(
            f"dli_secret_{entry['source']}",
            bucket=template_vars.get("DLI_DATAINTEGRATOR_BUCKET", ""),
            name=(
                f"{template_vars.get('DLI_DATAINTEGRATOR_PATH', '')}/secrets/"
                f"{entry.get('file_name')}.json"
            ),
            content=pulumi.Output.json_dumps(entry.get("content", {})),
            opts=opts,
        )
        secret_objects[entry["source"]] = obj

    return {
        "pipelines": pipeline_objects,
        "connectors": connector_objects,
        "secrets": secret_objects,
    }
