# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

"""
GCP Cloud Identity component.
References:
https://www.pulumi.com/registry/packages/gcp/api-docs/cloudidentity/
"""

from __future__ import annotations

from typing import Any, cast

import pulumi_gcp as gcp
from utils.json_reader import read_json_files, slugify
from utils.schemas import gcp_cloud_identity
from utils.validations import validate_entries
from variables import SRC_INFRA_PATH

import pulumi


def create_cloud_identity(
    template_vars: dict[str, str],
    opts: pulumi.ResourceOptions | None = None,
    json_files: list[dict[str, Any]] | None = None,
) -> Any:
    """
    Create Cloud Identity groups and memberships.

    Args:
        template_vars: Template variables for substitution
        opts: Pulumi resource options (opcional)
        json_files: (opcional) Loaded JSON files list for local tests.
            If None, use read_json_files(...) from SRC_INFRA_PATH.

    Returns:
        Dictionary containing created identity groups and memberships
    """
    # 1) Read JSONs (with variable substitution)
    if json_files is None:
        files = read_json_files(
            source_path=f"{SRC_INFRA_PATH}/gcp/auto/cloud_identity/",
            files_regex="**",
            template_vars=template_vars,
        )
    else:
        files = json_files

    # 2) Validate files, extract subdicts with security and create resources
    groups: list[Any] = []
    memberships: list[Any] = []
    for entry in files:
        content = entry.get("content", {}) or {}
        group: Any = None

        # 2.1) Validate files
        validate_entries(entries=[entry], schema=gcp_cloud_identity)

        # 2.2) Extract subdicts with security
        group_key = content.get("group_key", {}) or {}
        member_key = content.get("member_key", {}) or {}

        # 2.3) Create resources
        # -------- Group --------
        if group_key:
            group = gcp.cloudidentity.Group(
                resource_name=f"identity_group_{slugify(entry['file_name'])}",
                description=content.get("description"),
                display_name=content.get("display_name"),
                # gcp.cloudidentity.GroupGroupKeyArgs()
                group_key=cast(Any, group_key),
                initial_group_config=content.get("initial_group_config"),
                labels=content.get("labels"),
                parent=content.get("parent"),
                opts=opts,
            )
            groups.append(group)

        # -------- Membership --------
        if member_key:
            membership = gcp.cloudidentity.GroupMembership(
                resource_name=f"identity_membership_{slugify(entry['file_name'])}",
                group=group.id if group else content.get("group_id"),
                # gcp.cloudidentity.GroupMembershipMemberKeyArgs()
                member_key=cast(Any, content.get("member_key") or {}),
                # gcp.cloudidentity.GroupMembershipPreferredMemberKeyArgs()
                preferred_member_key=cast(
                    Any, content.get("preferred_member_key") or {}
                ),
                # gcp.cloudidentity.GroupMembershipRoleArgs()
                roles=content.get("roles") or [],
                opts=opts,
            )
            memberships.append(membership)

    return {
        "groups": groups,
        "memberships": memberships,
    }
