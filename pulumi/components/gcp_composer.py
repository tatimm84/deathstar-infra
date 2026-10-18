# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

"""
GCP Cloud Composer component.
Converted from terraform/gcp_composer.tf
"""

from __future__ import annotations

from typing import Any

import pulumi_gcp as gcp
from utils.json_reader import read_json_files
from variables import GCP_PROJECT, GCP_REGION, SRC_INFRA_PATH

import pulumi


def create_composer_environments(  # noqa: PLR0912
    template_vars: dict[str, str],
    opts: pulumi.ResourceOptions | None = None,
    json_files: list[dict[str, Any]] | None = None,
) -> dict[str, Any]:
    """
    Create Cloud Composer (Airflow) environments based on JSON configuration files.
    Files should be at root: infra/gcp/auto/composer/<any>.json

    Args:
        template_vars: Template variables for substitution
        opts: Pulumi resource options
        json_files: (opcional) Loaded JSON files list for local tests.
            If None, use read_json_files(...) from SRC_INFRA_PATH.

    Returns:
        Dictionary with created composer environments
    """
    # 1) Read JSONs (with variable substitution)
    if json_files is None:
        files = read_json_files(
            source_path=f"{SRC_INFRA_PATH}/gcp/auto/composer/",
            files_regex="*",
            template_vars=template_vars,
        )
    else:
        files = json_files

    # 2) Validate files and create resources
    composers: list[Any] = []
    for entry in files:
        content = entry.get("content", {}) or {}

        source = entry["source"]

        # Create Composer Environment
        if content.get("name") or entry.get("file_name"):
            env_args = {
                "name": content.get("name", entry.get("file_name")),
                "project": GCP_PROJECT,
                "region": content.get("location", GCP_REGION),
                "labels": content.get("labels"),
            }

            # Add config
            if content.get("config"):
                config = content["config"]
                config_args: dict[str, Any] = {}

                # Node config
                if config.get("node_config"):
                    config_args["node_config"] = (
                        gcp.composer.EnvironmentConfigNodeConfigArgs(
                            **config["node_config"]
                        )
                    )

                # Software config
                if config.get("software_config"):
                    config_args["software_config"] = (
                        gcp.composer.EnvironmentConfigSoftwareConfigArgs(
                            **config["software_config"]
                        )
                    )

                # Private environment config
                if config.get("private_environment_config"):
                    config_args["private_environment_config"] = (
                        gcp.composer.EnvironmentConfigPrivateEnvironmentConfigArgs(
                            **config["private_environment_config"]
                        )
                    )

                # Web server network access control
                if config.get("web_server_network_access_control"):
                    config_args["web_server_network_access_control"] = (
                        gcp.composer.EnvironmentConfigWebServerNetworkAccessControlArgs(
                            **config["web_server_network_access_control"]
                        )
                    )

                # Database config
                if config.get("database_config"):
                    config_args["database_config"] = (
                        gcp.composer.EnvironmentConfigDatabaseConfigArgs(
                            **config["database_config"]
                        )
                    )

                # Web server config
                if config.get("web_server_config"):
                    config_args["web_server_config"] = (
                        gcp.composer.EnvironmentConfigWebServerConfigArgs(
                            **config["web_server_config"]
                        )
                    )

                # Encryption config
                if config.get("encryption_config"):
                    config_args["encryption_config"] = (
                        gcp.composer.EnvironmentConfigEncryptionConfigArgs(
                            **config["encryption_config"]
                        )
                    )

                # Maintenance window
                if config.get("maintenance_window"):
                    config_args["maintenance_window"] = (
                        gcp.composer.EnvironmentConfigMaintenanceWindowArgs(
                            **config["maintenance_window"]
                        )
                    )

                # Workloads config
                if config.get("workloads_config"):
                    config_args["workloads_config"] = (
                        gcp.composer.EnvironmentConfigWorkloadsConfigArgs(
                            **config["workloads_config"]
                        )
                    )

                # Environment size
                if config.get("environment_size"):
                    config_args["environment_size"] = config["environment_size"]

                env_args["config"] = gcp.composer.EnvironmentConfigArgs(
                    **{k: v for k, v in config_args.items() if v is not None}
                )

            # Add storage config
            if content.get("storage_config"):
                env_args["storage_config"] = gcp.composer.EnvironmentStorageConfigArgs(
                    **content["storage_config"]
                )

            composer = gcp.composer.Environment(
                f"composer_env_{source}",
                **{k: v for k, v in env_args.items() if v is not None},
                opts=opts,
            )
            composers.append(composer)

    return {
        "composers": composers,
    }
