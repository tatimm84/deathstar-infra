# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

"""
GCP Dataform component.
Converted from terraform/gcp_dataform.tf and terraform/modules/gcp/dataform/
References:
https://www.pulumi.com/registry/packages/gcp/api-docs/dataform/
"""

from __future__ import annotations

from typing import Any

import pulumi_gcp as gcp
from utils.json_reader import read_json_files, slugify
from utils.schemas import gcp_dataform
from utils.validations import validate_entries
from variables import (
    ENVIRONMENT,
    GCP_PROJECT,
    GCP_REGION,
    PROJECT_NUMBER,
    RUNNING_SERVICE_ACCOUNT,
    SRC_INFRA_PATH,
    UID_NOW,
)

import pulumi


def create_dataform(
    template_vars: dict[str, str],
    opts: pulumi.ResourceOptions | None = None,
    json_files: list[dict[str, Any]] | None = None,
    extra_json_files: list[dict[str, Any]] | None = None,
) -> dict[str, Any]:
    """
    Create GCP Dataform repositories, release configs, workflow configs
    and IAM members based on JSON configuration files.
    Files should be at root: infra/gcp/auto/dataform/<any>.json

    Args:
        template_vars: Template variables for substitution
        opts: Pulumi resource options
        json_files: (optional) Loaded JSON files list for local tests.
            If None, use read_json_files(...) from SRC_INFRA_PATH.
        extra_json_files: Additional configurations to merge.

    Returns:
        Dictionary with created dataform resources:
          - repositories: list of Repository
          - release_configs: list of RepositoryReleaseConfig
          - workflow_configs: list of RepositoryWorkflowConfig
          - iam_members: list of RepositoryIamMember
    """
    # 1) Read JSONs (with variable substitution)
    if json_files is None:
        files = read_json_files(
            source_path=f"{SRC_INFRA_PATH}/gcp/auto/dataform/",
            files_regex="**",
            template_vars=template_vars,
        )
    else:
        files = list(json_files)

    # Merge extra_json_files if provided
    if extra_json_files:
        files.extend(extra_json_files)

    # 2) Create resources
    repositories: list[Any] = []
    release_configs: list[Any] = []
    workflow_configs: list[Any] = []
    iam_members: list[Any] = []

    for entry in files:
        content = entry.get("content", {}) or {}

        source = entry["source"]
        resource_id = slugify(source)

        # Validate entry
        validate_entries(entries=[entry], schema=gcp_dataform)

        # Resolve region
        region = content.get("region", "") or GCP_REGION

        # Resolve name
        name = content.get("name", "") or entry["file_name"]

        # -----------------------------------------------------------------
        # Repository
        # -----------------------------------------------------------------
        repository_create = content.get("repository_create", True)
        repository = None

        if repository_create:
            repo_args: dict[str, Any] = {
                "project": GCP_PROJECT,
                "region": region,
                "name": name,
                "deletion_policy": content.get("deletion_policy", "DELETE"),
            }

            # Optional fields
            if content.get("display_name"):
                repo_args["display_name"] = content["display_name"]
            if content.get("service_account"):
                repo_args["service_account"] = content["service_account"]
            if content.get("npmrc_environment_variables_secret_version"):
                repo_args["npmrc_environment_variables_secret_version"] = (
                    content["npmrc_environment_variables_secret_version"]
                )
            if content.get("kms_key_name"):
                repo_args["kms_key_name"] = content["kms_key_name"]
            if content.get("labels"):
                repo_args["labels"] = content["labels"]

            # Git remote settings
            git_remote_settings = content.get("git_remote_settings")
            if git_remote_settings is not None:
                grs_args: dict[str, Any] = {
                    "url": git_remote_settings.get("url", ""),
                    "default_branch": git_remote_settings.get(
                        "default_branch", "main"
                    ),
                }
                if git_remote_settings.get("authentication_token_secret_version"):
                    grs_args["authentication_token_secret_version"] = (
                        git_remote_settings["authentication_token_secret_version"]
                    )

                # SSH authentication config
                ssh_config = git_remote_settings.get("ssh_authentication_config")
                if ssh_config is not None:
                    grs_args["ssh_authentication_config"] = (
                        gcp.dataform.RepositoryGitRemoteSettingsSshAuthenticationConfigArgs(
                            user_private_key_secret_version=ssh_config.get(
                                "user_private_key_secret_version", ""
                            ),
                            host_public_key=ssh_config.get("host_public_key", ""),
                        )
                    )

                repo_args["git_remote_settings"] = (
                    gcp.dataform.RepositoryGitRemoteSettingsArgs(**grs_args)
                )

            # Workspace compilation overrides
            wco = content.get("workspace_compilation_overrides")
            if wco is not None:
                wco_args: dict[str, Any] = {}
                if wco.get("default_database"):
                    wco_args["default_database"] = wco["default_database"]
                if wco.get("schema_suffix"):
                    wco_args["schema_suffix"] = wco["schema_suffix"]
                if wco.get("table_prefix"):
                    wco_args["table_prefix"] = wco["table_prefix"]
                if wco_args:
                    repo_args["workspace_compilation_overrides"] = (
                        gcp.dataform.RepositoryWorkspaceCompilationOverridesArgs(
                            **wco_args
                        )
                    )

            repository = gcp.dataform.Repository(
                f"dataform_repo_{resource_id}",
                **repo_args,
                opts=opts,
            )
            repositories.append(repository)

        # Resolve the repository name for dependent resources.
        # If repository was created, use its name; otherwise use the provided name.
        repo_name_for_deps = repository.name if repository else name

        # -----------------------------------------------------------------
        # Release Config
        # -----------------------------------------------------------------
        release_config_data = content.get("release_config")
        release_config_create = release_config_data is not None

        release_config = None
        if release_config_create:
            rc_args: dict[str, Any] = {
                "project": GCP_PROJECT,
                "region": region,
                "repository": repo_name_for_deps,
                "name": release_config_data.get(
                    "name", f"{entry['file_name']}-release"
                ),
                "git_commitish": release_config_data.get("git_commitish", "main"),
            }

            if release_config_data.get("cron_schedule"):
                rc_args["cron_schedule"] = release_config_data["cron_schedule"]
            if release_config_data.get("time_zone"):
                rc_args["time_zone"] = release_config_data["time_zone"]

            # Code compilation config
            ccc = release_config_data.get("code_compilation_config")
            if ccc is not None:
                ccc_args: dict[str, Any] = {}
                if ccc.get("default_database"):
                    ccc_args["default_database"] = ccc["default_database"]
                if ccc.get("default_schema"):
                    ccc_args["default_schema"] = ccc["default_schema"]
                if ccc.get("default_location"):
                    ccc_args["default_location"] = ccc["default_location"]
                if ccc.get("assertion_schema"):
                    ccc_args["assertion_schema"] = ccc["assertion_schema"]
                if ccc.get("vars"):
                    ccc_args["vars"] = ccc["vars"]
                if ccc.get("database_suffix"):
                    ccc_args["database_suffix"] = ccc["database_suffix"]
                if ccc.get("schema_suffix"):
                    ccc_args["schema_suffix"] = ccc["schema_suffix"]
                if ccc.get("table_prefix"):
                    ccc_args["table_prefix"] = ccc["table_prefix"]
                if ccc_args:
                    rc_args["code_compilation_config"] = (
                        gcp.dataform.RepositoryReleaseConfigCodeCompilationConfigArgs(
                            **ccc_args
                        )
                    )

            rc_depends_on = (
                [repository] if repository else []
            )
            release_config = gcp.dataform.RepositoryReleaseConfig(
                f"dataform_release_{resource_id}",
                **rc_args,
                opts=pulumi.ResourceOptions(
                    depends_on=rc_depends_on,
                ),
            )
            release_configs.append(release_config)

        # -----------------------------------------------------------------
        # Workflow Config(s)
        # -----------------------------------------------------------------
        wf_config_data = content.get("workflow_config")
        if wf_config_data is not None:
            # Normalize: accept single dict or list of dicts
            if isinstance(wf_config_data, dict):
                wf_config_list = [wf_config_data]
            else:
                wf_config_list = list(wf_config_data)

            for wf_item in wf_config_list:
                wf_name = wf_item.get("name")
                if not wf_name:
                    continue

                wf_args: dict[str, Any] = {
                    "project": GCP_PROJECT,
                    "region": region,
                    "repository": repo_name_for_deps,
                    "name": wf_name,
                }

                # Release config reference
                if release_config_create and release_config is not None:
                    wf_args["release_config"] = release_config.id
                elif wf_item.get("release_config_id"):
                    wf_args["release_config"] = wf_item["release_config_id"]

                if wf_item.get("cron_schedule"):
                    wf_args["cron_schedule"] = wf_item["cron_schedule"]
                if wf_item.get("time_zone"):
                    wf_args["time_zone"] = wf_item["time_zone"]
                else:
                    wf_args["time_zone"] = "America/Sao_Paulo"

                # Invocation config
                inv_config = wf_item.get("invocation_config")
                if inv_config is not None:
                    inv_args: dict[str, Any] = {}
                    if inv_config.get(
                        "fully_refresh_incremental_tables_enabled"
                    ) is not None:
                        inv_args["fully_refresh_incremental_tables_enabled"] = (
                            inv_config["fully_refresh_incremental_tables_enabled"]
                        )
                    if inv_config.get("included_tags"):
                        inv_args["included_tags"] = inv_config["included_tags"]
                    if inv_config.get("transitive_dependencies_included") is not None:
                        inv_args["transitive_dependencies_included"] = (
                            inv_config["transitive_dependencies_included"]
                        )
                    if inv_config.get("transitive_dependents_included") is not None:
                        inv_args["transitive_dependents_included"] = (
                            inv_config["transitive_dependents_included"]
                        )
                    if inv_config.get("service_account"):
                        inv_args["service_account"] = inv_config["service_account"]

                    # Included targets
                    included_targets = inv_config.get("included_targets", [])
                    if included_targets:
                        inv_args["included_targets"] = [
                            gcp.dataform.RepositoryWorkflowConfigInvocationConfigIncludedTargetArgs(
                                database=t.get("database"),
                                schema=t.get("schema"),
                                name=t.get("name"),
                            )
                            for t in included_targets
                        ]

                    if inv_args:
                        wf_args["invocation_config"] = (
                            gcp.dataform.RepositoryWorkflowConfigInvocationConfigArgs(
                                **inv_args
                            )
                        )

                wf_depends_on = []
                if repository is not None:
                    wf_depends_on.append(repository)
                if release_config is not None:
                    wf_depends_on.append(release_config)

                wf = gcp.dataform.RepositoryWorkflowConfig(
                    f"dataform_wf_{slugify(wf_name)}_{resource_id}",
                    **wf_args,
                    opts=pulumi.ResourceOptions(
                        depends_on=wf_depends_on,
                    ),
                )
                workflow_configs.append(wf)


    return {
        "repositories": repositories,
        "release_configs": release_configs,
        "workflow_configs": workflow_configs
    }
