# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# WORKFLOWS
# --------------------------------------------------------------------
locals {
  workflow = module.json_workflow_reader.parsed_data
}

module "json_workflow_reader" {
  source = "./modules/utils/reader"

  source_path = "${var.SRC_INFRA_PATH}/gcp/auto/workflows/"
  enviroment  = var.ENVIRONMENT
  files_regex = "**"
  template_vars = {
    "__project_number__" = var.PROJECT_NUMBER,
    "__project_name__"   = var.GCP_PROJECT,
    "__region__"         = var.GCP_REGION,
    "__env__"            = var.ENVIRONMENT,
    "__uid_now__"        = var.UID_NOW
  }
}

module "gcp_workflows" {
  for_each        = { for entry in local.workflow : "${entry.source}" => entry }
  source          = "./modules/gcp/workflows"
  gcp_project     = var.GCP_PROJECT
  gcp_region      = lookup(each.value.content, "location", "") != "" ? lookup(each.value.content, "location") : var.GCP_REGION
  name            = each.value.file_name
  name_prefix     = lookup(each.value.content, "name_prefix", "") != "" ? lookup(each.value.content, "name_prefix") : null
  call_log_level  = lookup(each.value.content, "call_log_level", "") != "" ? lookup(each.value.content, "call_log_level") : null
  crypto_key_name = lookup(each.value.content, "crypto_key_name", "") != "" ? lookup(each.value.content, "crypto_key_name") : null
  description     = lookup(each.value.content, "description", "") != "" ? lookup(each.value.content, "description") : null
  labels          = lookup(each.value.content, "labels", {}) != {} ? lookup(each.value.content, "labels") : null
  service_account = lookup(each.value.content, "service_account", "") != "" ? lookup(each.value.content, "service_account") : null
  source_contents = lookup(each.value.content, "source_contents", "") != "" ? replace(jsonencode(lookup(each.value.content, "source_contents")), "__cond_init__", "$") : null
  user_env_vars   = lookup(each.value.content, "user_env_vars", {}) != {} ? lookup(each.value.content, "user_env_vars") : null
  depends_on      = [module.gcp_apis_services]
}
