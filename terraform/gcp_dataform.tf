# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# DATAFORM
# --------------------------------------------------------------------
locals {
  dataform = module.json_dataform_reader.parsed_data
}

module "json_dataform_reader" {
  source = "./modules/utils/reader"

  source_path = "${var.SRC_INFRA_PATH}/gcp/auto/dataform/"
  enviroment  = var.ENVIRONMENT
  files_regex = "**"
  template_vars = {
    "__project_number__"          = var.PROJECT_NUMBER,
    "__project_name__"            = var.GCP_PROJECT,
    "__region__"                  = var.GCP_REGION,
    "__running_service_account__" = var.RUNNING_SERVICE_ACCOUNT,
    "__env__"                     = var.ENVIRONMENT,
    "__uid_now__"                 = var.UID_NOW
  }
}

module "gcp_dataform" {
  for_each    = { for entry in local.dataform : "${entry.source}" => entry }
  source      = "./modules/gcp/dataform"
  gcp_project = var.GCP_PROJECT
  gcp_region  = lookup(each.value.content, "region", "") != "" ? lookup(each.value.content, "region") : var.GCP_REGION

  # Repository
  repository_create                          = lookup(each.value.content, "repository_create", true)
  name                                       = lookup(each.value.content, "name", "") != "" ? lookup(each.value.content, "name") : each.value.file_name
  display_name                               = lookup(each.value.content, "display_name", "") != "" ? lookup(each.value.content, "display_name") : null
  service_account                            = lookup(each.value.content, "service_account", "") != "" ? lookup(each.value.content, "service_account") : null
  npmrc_environment_variables_secret_version = lookup(each.value.content, "npmrc_environment_variables_secret_version", "") != "" ? lookup(each.value.content, "npmrc_environment_variables_secret_version") : null
  kms_key_name                               = lookup(each.value.content, "kms_key_name", "") != "" ? lookup(each.value.content, "kms_key_name") : null
  labels                                     = lookup(each.value.content, "labels", {}) != {} ? lookup(each.value.content, "labels") : null
  deletion_policy                            = lookup(each.value.content, "deletion_policy", "") != "" ? lookup(each.value.content, "deletion_policy") : "DELETE"

  # Git Remote Settings
  git_remote_settings = lookup(each.value.content, "git_remote_settings", null) != null ? {
    url                                 = lookup(each.value.content.git_remote_settings, "url", "")
    default_branch                      = lookup(each.value.content.git_remote_settings, "default_branch", "main")
    authentication_token_secret_version = lookup(each.value.content.git_remote_settings, "authentication_token_secret_version", null)
    ssh_authentication_config = lookup(each.value.content.git_remote_settings, "ssh_authentication_config", null) != null ? {
      user_private_key_secret_version = lookup(each.value.content.git_remote_settings.ssh_authentication_config, "user_private_key_secret_version", "")
      host_public_key                 = lookup(each.value.content.git_remote_settings.ssh_authentication_config, "host_public_key", "")
    } : null
  } : null

  # Workspace Compilation Overrides
  workspace_compilation_overrides = lookup(each.value.content, "workspace_compilation_overrides", null) != null ? {
    default_database = lookup(each.value.content.workspace_compilation_overrides, "default_database", null)
    schema_suffix    = lookup(each.value.content.workspace_compilation_overrides, "schema_suffix", null)
    table_prefix     = lookup(each.value.content.workspace_compilation_overrides, "table_prefix", null)
  } : null

  # Release Config
  release_config_create = lookup(each.value.content, "release_config", null) != null
  release_config_name   = lookup(each.value.content, "release_config", null) != null ? lookup(each.value.content.release_config, "name", "${each.value.file_name}-release") : null
  git_commitish         = lookup(each.value.content, "release_config", null) != null ? lookup(each.value.content.release_config, "git_commitish", "main") : "main"
  cron_schedule         = lookup(each.value.content, "release_config", null) != null ? lookup(each.value.content.release_config, "cron_schedule", null) : null
  time_zone             = lookup(each.value.content, "release_config", null) != null ? lookup(each.value.content.release_config, "time_zone", "America/Sao_Paulo") : "America/Sao_Paulo"

  # Code Compilation Config
  code_compilation_config = lookup(each.value.content, "release_config", null) != null && lookup(each.value.content.release_config, "code_compilation_config", null) != null ? {
    default_database = lookup(each.value.content.release_config.code_compilation_config, "default_database", null)
    default_schema   = lookup(each.value.content.release_config.code_compilation_config, "default_schema", null)
    default_location = lookup(each.value.content.release_config.code_compilation_config, "default_location", null)
    assertion_schema = lookup(each.value.content.release_config.code_compilation_config, "assertion_schema", null)
    vars             = lookup(each.value.content.release_config.code_compilation_config, "vars", null)
    database_suffix  = lookup(each.value.content.release_config.code_compilation_config, "database_suffix", null)
    schema_suffix    = lookup(each.value.content.release_config.code_compilation_config, "schema_suffix", null)
    table_prefix     = lookup(each.value.content.release_config.code_compilation_config, "table_prefix", null)
  } : null

  # Workflow Config
  workflow_config = lookup(each.value.content, "workflow_config", null)

  # IAM Members
  iam_members = lookup(each.value.content, "iam_members", {}) != {} ? { for k, v in lookup(each.value.content, "iam_members") : k => v } : {}

  depends_on = [module.gcp_apis_services]
}
