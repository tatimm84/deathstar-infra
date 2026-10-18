# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

"""
GCP Secret Manager component.
Reference:
https://www.pulumi.com/registry/packages/gcp/api-docs/secretmanager/
"""

from __future__ import annotations

from typing import Any

import pulumi_gcp as gcp
from utils.json_reader import read_json_files, slugify
from utils.schemas import gcp_secret_manager
from utils.validations import validate_entries
from variables import GCP_PROJECT, SRC_INFRA_PATH

import pulumi


def create_secret_manager(
    template_vars: dict[str, str],
    opts: pulumi.ResourceOptions | None = None,
    json_files: list[dict[str, Any]] | None = None,
) -> dict[str, Any]:
    """
    Create secrets in GCP Secret Manager based on JSON configuration files.
    Files should be at root: infra/gcp/auto/secret_manager/<any>.json

    Args:
        template_vars: Template variables for substitution
        opts: Pulumi resource options
        json_files: (opcional) Loaded JSON files list for local tests.
            If None, use read_json_files(...) from SRC_INFRA_PATH.

    Returns:
        List of created secrets
    """
    # 1) Read JSONs (with variable substitution)
    if json_files is None:
        files = read_json_files(
            source_path=f"{SRC_INFRA_PATH}/gcp/auto/secret_manager/",
            files_regex="**",
            template_vars=template_vars,
        )
    else:
        files = json_files

    # 2) Validate files and create resources
    secrets: list[Any] = []
    for entry in files:
        content = entry.get("content", {}) or {}

        # 2.1) Validate files
        validate_entries(entries=[entry], schema=gcp_secret_manager)

        # 2.2) Create resources
        # -------- Secret --------
        secret = gcp.secretmanager.Secret(
            resource_name=f"secret_{slugify(entry['file_name'])}",
            annotations=content.get("annotations"),
            expire_time=content.get("expire_time"),
            labels=content.get("labels"),
            project=GCP_PROJECT,
            # gcp.secretmanager.SecretReplicationArgs()
            replication=content.get("replication"),
            # gcp.secretmanager.SecretRotationArgs()
            rotation=content.get("rotation"),
            secret_id=content.get("secret_id", entry["file_name"]),
            # list(gcp.secretmanager.SecretTopicArgs())
            topics=content.get("topics"),
            ttl=content.get("ttl"),
            version_aliases=content.get("version_aliases"),
            version_destroy_ttl=content.get("version_destroy_ttl"),
            opts=opts,
        )
        secrets.append(secret)

        # -------- SecretVersion --------
        if content.get("secret_data") is not None:
            gcp.secretmanager.SecretVersion(
                resource_name=f"secret_version_{slugify(entry['file_name'])}",
                deletion_policy=content["deletion_policy"],
                enabled=content["enabled"],
                is_secret_data_base64=content["is_secret_data_base64"],
                project=GCP_PROJECT,
                secret=secret.id,
                secret_data=content["secret_data"],
                secret_data_wo=content["secret_data_wo"],
                secret_data_wo_version=content["secret_data_wo_version"],
                opts=pulumi.ResourceOptions(parent=secret),
            )

    return {"secrets": secrets}
