"""
GCP IAM component.
References:
https://www.pulumi.com/registry/packages/gcp/api-docs/projects/iammember/
https://www.pulumi.com/registry/packages/gcp/api-docs/projects/iambinding/
"""

from __future__ import annotations

from typing import Any

import pulumi_gcp as gcp
from utils.json_reader import read_json_files, slugify
from utils.schemas import gcp_iam
from utils.validations import validate_entries
from variables import GCP_PROJECT, SRC_INFRA_PATH

import pulumi


def create_iam(
    template_vars: dict[str, str],
    opts: pulumi.ResourceOptions | None = None,
    json_files: list[dict[str, Any]] | None = None,
    extra_json_files: list[dict[str, Any]] | None = None,
) -> dict[str, Any]:
    """
    Create IAM bindings based on JSON configuration files.

    Args:
        template_vars: Template variables for substitution
        opts: Pulumi resource options
        json_files: Loaded JSON files list for local tests.
            If None, use read_json_files(...) from SRC_INFRA_PATH.
        extra_json_files: Additional configurations to merge.

    Returns:
        Dictionary containing created IAMs
    """
    # 1) Read JSONs (with variable substitution)
    if json_files is None:
        files = read_json_files(
            source_path=f"{SRC_INFRA_PATH}/gcp/auto/iam/",
            files_regex="**",
            template_vars=template_vars,
        )
    else:
        files = list(json_files)

    if extra_json_files:
        files.extend(extra_json_files)

    # 2) Validate files and create resources
    iams: list[Any] = []
    for entry in files:
        content = entry.get("content", {}) or {}

        # 2.1) Validate files
        validate_entries(entries=[entry], schema=gcp_iam)

        # 2.2) Create resources
        for role in content.get("roles", []):
            for member in content.get("members", []):
                iam_type = content.get("type")
                if iam_type == "member":
                    iam = gcp.projects.IAMMember(
                        resource_name=f"iam_{slugify(entry['file_name'])}_{slugify(role)}_{slugify(member)}",
                        condition=content.get("condition"),
                        member=member,
                        project=GCP_PROJECT,
                        role=role,
                        opts=opts,
                    )
                elif iam_type == "binding":
                    iam = gcp.projects.IAMBinding(
                        resource_name=f"iam_{slugify(entry['file_name'])}_{slugify(role)}_{slugify(member)}",
                        condition=content.get("condition"),
                        members=[member],
                        project=GCP_PROJECT,
                        role=role,
                        opts=opts,
                    )
                iams.append(iam)

    return {
        "iams": iams,
    }
