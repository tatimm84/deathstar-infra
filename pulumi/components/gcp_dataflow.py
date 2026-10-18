# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

"""GCP Dataflow component."""

from __future__ import annotations

from typing import Any

import pulumi_gcp as gcp
from utils.json_reader import read_json_files
from variables import GCP_PROJECT, GCP_REGION, SRC_INFRA_PATH

import pulumi


def create_dataflow_jobs(
    template_vars: dict[str, str],
    opts: pulumi.ResourceOptions | None = None,
    json_files: list[dict[str, Any]] | None = None,
) -> dict[str, Any]:
    """
    Create Dataflow jobs based on JSON configuration files.
    Files should be at root: infra/gcp/auto/dataflow/<any>.json

    Args:
        template_vars: Template variables for substitution
        opts: Pulumi resource options (opcional)
        json_files: (opcional) Loaded JSON files list for local tests.
            If None, use read_json_files(...) from SRC_INFRA_PATH.

    Returns:
        Dictionary with created Dataflow jobs
    """
    # 1) Read JSONs (with variable substitution)
    if json_files is None:
        files = read_json_files(
            source_path=f"{SRC_INFRA_PATH}/gcp/auto/dataflow/",
            files_regex="**",
            template_vars=template_vars,
        )
    else:
        files = json_files

    # 2) Validate files and create resources
    jobs: list[Any] = []
    for entry in files:
        content = entry.get("content", {}) or {}

        job = gcp.dataflow.Job(
            f"dataflow_job_{entry['source']}",
            name=entry.get("file_name"),
            project=GCP_PROJECT,
            region=content.get("location", GCP_REGION),
            zone=content.get("zone"),
            template_gcs_path=content.get("template_gcs_path"),
            temp_gcs_location=content.get("temp_gcs_location"),
            parameters=content.get("parameters"),
            labels=content.get("labels"),
            transform_name_mapping=content.get("transform_name_mapping"),
            max_workers=content.get("max_workers"),
            on_delete=content.get("on_delete"),
            skip_wait_on_job_termination=content.get("skip_wait_on_job_termination"),
            service_account_email=content.get("service_account_email"),
            network=content.get("network"),
            subnetwork=content.get("subnetwork"),
            machine_type=content.get("machine_type"),
            kms_key_name=content.get("kms_key_name"),
            ip_configuration=content.get("ip_configuration"),
            additional_experiments=content.get("additional_experiments"),
            enable_streaming_engine=content.get("enable_streaming_engine"),
            opts=opts,
        )
        jobs.append(job)

    return {"jobs": jobs}
