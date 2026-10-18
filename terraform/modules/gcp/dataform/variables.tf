# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# GCP PROJECT
# --------------------------------------------------------------------
variable "gcp_project" {
  type        = string
  description = "GCP project id"
}
variable "gcp_region" {
  type        = string
  description = "GCP region"
  default     = "southamerica-east1"
}

# --------------------------------------------------------------------
# DATAFORM - REPOSITORY
# --------------------------------------------------------------------
variable "repository_create" {
  type        = bool
  description = "Whether to create the Dataform repository"
  default     = true
}
variable "name" {
  type        = string
  description = "The repository's name"
}
variable "display_name" {
  type        = string
  description = "Optional. The repository's user-friendly name"
  default     = null
}
variable "service_account" {
  type        = string
  description = "The service account to run workflow invocations under"
  default     = null
}
variable "npmrc_environment_variables_secret_version" {
  type        = string
  description = "Optional. The name of the Secret Manager secret version for .npmrc file interpolation"
  default     = null
}
variable "kms_key_name" {
  type        = string
  description = "Optional. The reference to a KMS encryption key"
  default     = null
}
variable "labels" {
  type        = map(string)
  description = "Optional. Repository user labels"
  default     = null
}
variable "deletion_policy" {
  type        = string
  description = "Policy to control how the repository is deleted. Possible values: DELETE, FORCE"
  default     = "DELETE"
}
variable "git_remote_settings" {
  type = object({
    url                                 = string
    default_branch                      = string
    authentication_token_secret_version = optional(string)
    ssh_authentication_config = optional(object({
      user_private_key_secret_version = string
      host_public_key                 = string
    }))
  })
  description = "Optional. Git remote settings for the repository"
  default     = null
}
variable "workspace_compilation_overrides" {
  type = object({
    default_database = optional(string)
    schema_suffix    = optional(string)
    table_prefix     = optional(string)
  })
  description = "Optional. Workspace compilation overrides"
  default     = null
}

# --------------------------------------------------------------------
# DATAFORM - REPOSITORY RELEASE CONFIG
# --------------------------------------------------------------------
variable "release_config_create" {
  type        = bool
  description = "Whether to create the release config"
  default     = false
}
variable "release_config_name" {
  type        = string
  description = "The release config's name"
  default     = null
}
variable "git_commitish" {
  type        = string
  description = "Git commitish in the remote repository"
  default     = "main"
}
variable "cron_schedule" {
  type        = string
  description = "Optional. Cron schedule for automatic release creation"
  default     = null
}
variable "time_zone" {
  type        = string
  description = "Optional. Time zone for the cron schedule"
  default     = "America/Sao_Paulo"
}
variable "code_compilation_config" {
  type = object({
    default_database = optional(string)
    default_schema   = optional(string)
    default_location = optional(string)
    assertion_schema = optional(string)
    vars             = optional(map(string))
    database_suffix  = optional(string)
    schema_suffix    = optional(string)
    table_prefix     = optional(string)
  })
  description = "Optional. Code compilation configuration"
  default     = null
}

# --------------------------------------------------------------------
# DATAFORM - REPOSITORY WORKFLOW CONFIG
# --------------------------------------------------------------------
variable "workflow_config" {
  type        = any
  description = <<-EOT
    Workflow configuration(s) for Dataform. Accepts either a single object or a list of objects.
    Each object supports the following attributes:
      - name                  (required) - The workflow config's name
      - release_config_id     (optional) - The release config ID (when not creating release config in this module)
      - cron_schedule          (optional) - Cron schedule for workflow execution
      - time_zone              (optional) - Time zone for the cron schedule (default: America/Sao_Paulo)
      - invocation_config      (optional) - Invocation configuration object:
          - fully_refresh_incremental_tables_enabled (optional, bool)
          - included_tags                            (optional, list(string))
          - transitive_dependencies_included         (optional, bool)
          - transitive_dependents_included           (optional, bool)
          - service_account                          (optional, string)
          - included_targets                         (optional, list of objects with database, schema, name)
  EOT
  default     = null
}

# --------------------------------------------------------------------
# DATAFORM - REPOSITORY IAM
# --------------------------------------------------------------------
variable "iam_members" {
  type = map(object({
    role   = string
    member = string
  }))
  description = "IAM members to add to the repository"
  default     = {}
}
