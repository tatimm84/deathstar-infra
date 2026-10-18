# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# DATAFORM - REPOSITORY
# --------------------------------------------------------------------
resource "google_dataform_repository" "repository" {
  count                                      = var.repository_create ? 1 : 0
  provider                                   = google-beta
  project                                    = var.gcp_project
  region                                     = var.gcp_region
  name                                       = var.name
  display_name                               = var.display_name
  service_account                            = var.service_account
  npmrc_environment_variables_secret_version = var.npmrc_environment_variables_secret_version
  kms_key_name                               = var.kms_key_name
  labels                                     = var.labels
  deletion_policy                            = var.deletion_policy

  dynamic "git_remote_settings" {
    for_each = var.git_remote_settings != null ? [var.git_remote_settings] : []
    content {
      url                                 = git_remote_settings.value.url
      default_branch                      = git_remote_settings.value.default_branch
      authentication_token_secret_version = lookup(git_remote_settings.value, "authentication_token_secret_version", null)

      dynamic "ssh_authentication_config" {
        for_each = lookup(git_remote_settings.value, "ssh_authentication_config", null) != null ? [git_remote_settings.value.ssh_authentication_config] : []
        content {
          user_private_key_secret_version = ssh_authentication_config.value.user_private_key_secret_version
          host_public_key                 = ssh_authentication_config.value.host_public_key
        }
      }
    }
  }

  dynamic "workspace_compilation_overrides" {
    for_each = var.workspace_compilation_overrides != null ? [var.workspace_compilation_overrides] : []
    content {
      default_database = lookup(workspace_compilation_overrides.value, "default_database", null)
      schema_suffix    = lookup(workspace_compilation_overrides.value, "schema_suffix", null)
      table_prefix     = lookup(workspace_compilation_overrides.value, "table_prefix", null)
    }
  }
}

# --------------------------------------------------------------------
# DATAFORM - REPOSITORY RELEASE CONFIG
# --------------------------------------------------------------------
resource "google_dataform_repository_release_config" "release_config" {
  count         = var.release_config_create ? 1 : 0
  provider      = google-beta
  project       = var.gcp_project
  region        = var.gcp_region
  repository    = var.repository_create ? google_dataform_repository.repository[0].name : var.name
  name          = var.release_config_name
  git_commitish = var.git_commitish
  cron_schedule = var.cron_schedule
  time_zone     = var.time_zone

  dynamic "code_compilation_config" {
    for_each = var.code_compilation_config != null ? [var.code_compilation_config] : []
    content {
      default_database = lookup(code_compilation_config.value, "default_database", null)
      default_schema   = lookup(code_compilation_config.value, "default_schema", null)
      default_location = lookup(code_compilation_config.value, "default_location", null)
      assertion_schema = lookup(code_compilation_config.value, "assertion_schema", null)
      vars             = lookup(code_compilation_config.value, "vars", null)
      database_suffix  = lookup(code_compilation_config.value, "database_suffix", null)
      schema_suffix    = lookup(code_compilation_config.value, "schema_suffix", null)
      table_prefix     = lookup(code_compilation_config.value, "table_prefix", null)
    }
  }

  depends_on = [google_dataform_repository.repository]
}

# --------------------------------------------------------------------
# DATAFORM - REPOSITORY WORKFLOW CONFIG
# --------------------------------------------------------------------
locals {
  # Normalize workflow_config: accept null, a single object, or a list of objects
  _workflow_config_list = (
    var.workflow_config == null ? [] :
    try(tolist(var.workflow_config), [var.workflow_config])
  )
  workflow_configs = { for wf in local._workflow_config_list : wf.name => wf }
}

resource "google_dataform_repository_workflow_config" "workflow_config" {
  for_each       = local.workflow_configs
  provider       = google-beta
  project        = var.gcp_project
  region         = var.gcp_region
  repository     = var.repository_create ? google_dataform_repository.repository[0].name : var.name
  name           = each.value.name
  release_config = var.release_config_create ? google_dataform_repository_release_config.release_config[0].id : lookup(each.value, "release_config_id", null)
  cron_schedule  = lookup(each.value, "cron_schedule", null)
  time_zone      = lookup(each.value, "time_zone", "America/Sao_Paulo")

  dynamic "invocation_config" {
    for_each = lookup(each.value, "invocation_config", null) != null ? [each.value.invocation_config] : []
    content {
      fully_refresh_incremental_tables_enabled = lookup(invocation_config.value, "fully_refresh_incremental_tables_enabled", null)
      included_tags                            = lookup(invocation_config.value, "included_tags", null)
      transitive_dependencies_included         = lookup(invocation_config.value, "transitive_dependencies_included", null)
      transitive_dependents_included           = lookup(invocation_config.value, "transitive_dependents_included", null)
      service_account                          = lookup(invocation_config.value, "service_account", null)

      dynamic "included_targets" {
        for_each = lookup(invocation_config.value, "included_targets", [])
        content {
          database = lookup(included_targets.value, "database", null)
          schema   = lookup(included_targets.value, "schema", null)
          name     = lookup(included_targets.value, "name", null)
        }
      }
    }
  }

  depends_on = [google_dataform_repository_release_config.release_config]
}

# --------------------------------------------------------------------
# DATAFORM - REPOSITORY IAM MEMBER
# --------------------------------------------------------------------
resource "google_dataform_repository_iam_member" "member" {
  for_each   = var.iam_members
  provider   = google-beta
  project    = var.gcp_project
  region     = var.gcp_region
  repository = var.repository_create ? google_dataform_repository.repository[0].name : var.name
  role       = each.value.role
  member     = each.value.member
  depends_on = [google_dataform_repository.repository]
}
