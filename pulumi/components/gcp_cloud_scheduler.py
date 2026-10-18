# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

"""
GCP Cloud Scheduler component.
References:
https://www.pulumi.com/registry/packages/gcp/api-docs/cloudscheduler/
"""

from __future__ import annotations

from typing import Any

import pulumi_gcp as gcp
from utils.json_reader import read_json_files, slugify
from utils.schemas import gcp_cloud_scheduler_job
from utils.validations import validate_entries
from variables import GCP_PROJECT, GCP_REGION, SRC_INFRA_PATH

import pulumi


def create_cloud_scheduler(
    template_vars: dict[str, str],
    opts: pulumi.ResourceOptions | None = None,
    json_files: list[dict[str, Any]] | None = None,
    extra_json_files: list[dict[str, Any]] | None = None,
) -> dict[str, Any]:
    """
    Create Cloud Scheduler jobs based on JSON configuration files.
    Files should be at root: infra/gcp/auto/cloud_scheduler/<any>.json

    Args:
        template_vars: Template variables for substitution
        opts: Pulumi resource options (opcional)
        json_files: (opcional) Loaded JSON files list for local tests.
            If None, use read_json_files(...) from SRC_INFRA_PATH.
        extra_json_files: Additional configurations to merge.

    Returns:
        Dictionary with created Cloud Scheduler jobs
    """
    # 1) Read JSONs (with variable substitution)
    if json_files is None:
        files = read_json_files(
            source_path=f"{SRC_INFRA_PATH}/gcp/auto/cloud_scheduler/",
            files_regex="**",
            template_vars=template_vars,
        )
    else:
        files = list(json_files)

    if extra_json_files:
        files.extend(extra_json_files)

    # 2) Validate files and create resources
    jobs: list[Any] = []
    for entry in files:
        content = entry.get("content", {}) or {}

        # 2.1) Validate files
        validate_entries(entries=[entry], schema=gcp_cloud_scheduler_job)

        # 2.2) Create resources
        job = gcp.cloudscheduler.Job(
            resource_name=f"scheduler_job_{slugify(entry['file_name'])}",
            # gcp.cloudscheduler.JobAppEngineHttpTargetArgs()
            app_engine_http_target=content.get("app_engine_http_target") or None,
            attempt_deadline=content.get("attempt_deadline"),
            description=content.get("description"),
            # gcp.cloudscheduler.JobHttpTargetArgs()
            http_target=content.get("http_target") or None,
            name=content.get("name", entry["file_name"]),
            paused=content.get("paused"),
            project=GCP_PROJECT,
            # gcp.cloudscheduler.JobPubsubTargetArgs()
            pubsub_target=content.get("pubsub_target") or None,
            region=content.get("location", GCP_REGION),
            # gcp.cloudscheduler.JobRetryConfigArgs()
            retry_config=content.get("retry_config"),
            schedule=content.get("schedule"),
            time_zone=content.get("time_zone", "UTC"),
            opts=opts,
        )
        jobs.append(job)

    return {"jobs": jobs}
