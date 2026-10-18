# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

"""
GCP API Services component.
References:
https://www.pulumi.com/registry/packages/gcp/api-docs/projects/
https://www.pulumi.com/registry/packages/gcp/api-docs/projects/service/
"""

from __future__ import annotations

from typing import Any

import pulumi_gcp as gcp
from utils.json_reader import read_json_files, slugify
from utils.schemas import gcp_api_service
from utils.validations import validate_entries
from variables import GCP_PROJECT, SRC_INFRA_PATH

import pulumi


def create_api_services(
    template_vars: dict[str, str],
    opts: pulumi.ResourceOptions | None = None,
    json_files: list[dict[str, Any]] | None = None,
) -> dict[str, Any]:
    """
    Enable GCP API services based on JSON configuration files.
    Files should be at root: infra/gcp/auto/apis_services/<any>.json

    Args:
        template_vars: Template variables for substitution
        opts: Pulumi resource options
        json_files: (opcional) Loaded JSON files list for local tests.
            If None, use read_json_files(...) from SRC_INFRA_PATH.

    Returns:
        Dictionary of created API service resources
    """
    # 1) Read JSONs (with variable substitution)
    if json_files is None:
        files = read_json_files(
            source_path=f"{SRC_INFRA_PATH}/gcp/auto/apis_services/",
            files_regex="**",
            template_vars=template_vars,
        )
    else:
        files = json_files

    # 2) Validate files, remove duplicated services and flatten services from all files
    created_services: list[Any] = []
    for entry in files:
        content = entry.get("content", {}) or {}

        # 2.1) Validate files
        validate_entries(entries=[entry], schema=gcp_api_service)

        # 2.2) Remove duplicated services and order serviceusage.googleapis.com first
        unique_services: list[Any] = []
        content = entry.get("content", {}) or {}
        for service in content.get("services", []):
            if service not in unique_services:
                unique_services.append(service)
        unique_services.sort(key=lambda x: (x != "serviceusage.googleapis.com", x))

        # 2.3) Create resources
        for service in unique_services:
            api_service = gcp.projects.Service(
                resource_name=f"service_{slugify(entry['file_name'])}",
                check_if_service_has_usage_on_destroy=content.get(
                    "check_if_service_has_usage_on_destroy"
                ),
                disable_dependent_services=content.get("disable_dependent_services"),
                disable_on_destroy=content.get("disable_on_destroy"),
                project=GCP_PROJECT,
                service=service,
                opts=opts,
            )
            created_services.append(api_service)

    return {"services": created_services}
