# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

"""
GCP Tasks component.
References:
https://www.pulumi.com/registry/packages/gcp/api-docs/cloudtasks/
"""

from __future__ import annotations

from typing import Any

import pulumi_gcp as gcp
from utils.json_reader import read_json_files, slugify
from utils.schemas import gcp_tasks
from utils.validations import validate_entries
from variables import GCP_PROJECT, GCP_REGION, SRC_INFRA_PATH

import pulumi


def create_tasks(
    template_vars: dict[str, str],
    opts: pulumi.ResourceOptions | None = None,
    json_files: list[dict[str, Any]] | None = None,
) -> dict[str, Any]:
    """
    Create GCP Tasks based on JSON configuration files.
    Files should be at root: infra/gcp/auto/tasks/<any>.json

    Args:
        template_vars: Template variables for substitution
        opts: Pulumi resource options (opcional)
        json_files: (opcional) Loaded JSON files list for local tests.
            If None, use read_json_files(...) from SRC_INFRA_PATH.

    Returns:
        List of created GCP Tasks
    """
    # 1) Read JSONs (with variable substitution)
    if json_files is None:
        files = read_json_files(
            source_path=f"{SRC_INFRA_PATH}/gcp/auto/tasks/",
            files_regex="**",
            template_vars=template_vars,
        )
    else:
        files = json_files

    # 2) Validate files and create resources
    queues: list[Any] = []
    for entry in files:
        content = entry.get("content", {}) or {}

        # 2.1) Validate files
        validate_entries(entries=[entry], schema=gcp_tasks)

        # 2.2) Create resources
        location = content.get("location", GCP_REGION)
        # -------- Queue --------
        queue = gcp.cloudtasks.Queue(
            resource_name=f"cloud-tasks-{slugify(entry['file_name'])}",
            location=location,
            # gcp.cloudtasks.QueueAppEngineRoutingOverrideArgs()
            app_engine_routing_override=content.get("app_engine_routing_override"),
            desired_state=content.get("desired_state"),
            # gcp.cloudtasks.QueueHttpTargetArgs()
            http_target=content.get("http_target"),
            name=content.get("name"),
            project=GCP_PROJECT,
            # gcp.cloudtasks.QueueRateLimitsArgs()
            rate_limits=content.get("rate_limits"),
            # gcp.cloudtasks.QueueRetryConfigArgs()
            retry_config=content.get("retry_config"),
            # gcp.cloudtasks.QueueStackdriverLoggingConfigArgs()
            stackdriver_logging_config=content.get("stackdriver_logging_config"),
            opts=opts,
        )
        queues.append(queue)

    return {"queues": queues}
