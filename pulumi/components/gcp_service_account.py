"""
GCP Service Account component.
References:
https://www.pulumi.com/registry/packages/gcp/api-docs/serviceaccount/account/
"""

from __future__ import annotations

from typing import Any

import pulumi_gcp as gcp
from utils.json_reader import read_json_files, slugify
from utils.schemas import gcp_service_account
from utils.validations import validate_entries
from variables import GCP_PROJECT, SRC_INFRA_PATH

import pulumi


def create_service_account(
    template_vars: dict[str, str],
    opts: pulumi.ResourceOptions | None = None,
    json_files: list[dict[str, Any]] | None = None,
    extra_json_files: list[dict[str, Any]] | None = None,
) -> dict[str, Any]:
    """
    Create Service Accounts based on JSON configuration files.
    Files should be at root: infra/gcp/auto/service_account/<any>.json

    Args:
        template_vars: Template variables for substitution
        opts: Pulumi resource options
        json_files: Loaded JSON files list for local tests.
            If None, use read_json_files(...) from SRC_INFRA_PATH.
        extra_json_files: Additional configurations to merge.

    Returns:
        Dictionary of created Service Accounts.
    """
    # 1) Read JSONs (with variable substitution)
    if json_files is None:
        files = read_json_files(
            source_path=f"{SRC_INFRA_PATH}/gcp/auto/service_account/",
            files_regex="**",
            template_vars=template_vars,
        )
    else:
        files = list(json_files)

    if extra_json_files:
        files.extend(extra_json_files)

    # 2) Validate files and create resources
    service_accounts: list[Any] = []
    for entry in files:
        content = entry.get("content", {}) or {}

        # 2.1) Validate files
        validate_entries(entries=[entry], schema=gcp_service_account)

        # 2.2) Create resources
        account_id = content.get("account_id")
        sa = gcp.serviceaccount.Account(
            resource_name=f"sa_{slugify(entry.get('file_name') or '')}",
            account_id=account_id,
            create_ignore_already_exists=content.get(
                "create_ignore_already_exists", False
            ),
            deletion_policy=content.get("deletion_policy", "DELETE"),
            description=content.get("description", "Managed by Pulumi"),
            disabled=content.get("disabled", False),
            display_name=content.get("display_name", f"SA for {account_id}"),
            project=GCP_PROJECT,
            opts=opts,
        )
        service_accounts.append(sa)

    return {
        "service_accounts": service_accounts,
    }
