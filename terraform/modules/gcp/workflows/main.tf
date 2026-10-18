# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# WORKFLOWS
# --------------------------------------------------------------------
resource "google_workflows_workflow" "workflow" {
  project         = var.gcp_project
  region          = var.gcp_region
  name            = var.name
  name_prefix     = var.name_prefix
  call_log_level  = var.call_log_level
  crypto_key_name = var.crypto_key_name
  description     = var.description
  labels          = var.labels
  service_account = var.service_account
  source_contents = var.source_contents
  user_env_vars   = var.user_env_vars
}
