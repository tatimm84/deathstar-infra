# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

"""
GCP Workflows component.
References:
https://www.pulumi.com/registry/packages/gcp/api-docs/workflows/
"""

from __future__ import annotations

from typing import Any

import pulumi_gcp as gcp
from utils.json_reader import read_json_files, slugify
from utils.schemas import gcp_workflows
from utils.validations import validate_entries
from variables import GCP_PROJECT, GCP_REGION, SRC_INFRA_PATH

import pulumi


def create_workflows(
    template_vars: dict[str, str],
    opts: pulumi.ResourceOptions | None = None,
    json_files: list[dict[str, Any]] | None = None,
) -> dict[str, Any]:
    """
    Create GCP Workflows based on JSON configuration files.
    Files should be at root: infra/gcp/auto/workflows/<any>.json

    Args:
        template_vars: Template variables for substitution
        opts: Pulumi resource options (opcional)
        json_files: (opcional) Loaded JSON files list for local tests.
            If None, use read_json_files(...) from SRC_INFRA_PATH.

    Returns:
        List of created GCP Workflows
    """
    # 1) Read JSONs (with variable substitution)
    if json_files is None:
        files = read_json_files(
            source_path=f"{SRC_INFRA_PATH}/gcp/auto/workflows/",
            files_regex="**",
            template_vars=template_vars,
        )
    else:
        files = json_files

    # 2) Validate files and create resources
    workflows: list[Any] = []
    for entry in files:
        content = entry.get("content", {}) or {}

        # 2.1) Validate files
        validate_entries(entries=[entry], schema=gcp_workflows)

        # 2.2) Create resources
        workflow = gcp.workflows.Workflow(
            resource_name=f"workflow_{slugify(entry['file_name'])}",
            call_log_level=content.get("call_log_level"),
            crypto_key_name=content.get("crypto_key_name"),
            deletion_protection=content.get("deletion_protection"),
            description=content.get("description"),
            execution_history_level=content.get("execution_history_level"),
            labels=content.get("labels"),
            name=content.get("name", entry["file_name"]),
            name_prefix=content.get("name_prefix"),
            project=GCP_PROJECT,
            region=content.get("location", GCP_REGION),
            service_account=content.get("service_account"),
            source_contents=content.get("source_contents"),
            tags=content.get("tags"),
            user_env_vars=content.get("user_env_vars"),
            opts=opts,
        )
        workflows.append(workflow)

    return {"workflows": workflows}
