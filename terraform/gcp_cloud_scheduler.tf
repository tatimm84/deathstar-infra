# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# CLOUD SCHEDULER
# --------------------------------------------------------------------
locals {
  scheduler = module.json_scheduler_reader.parsed_data
}

module "json_scheduler_reader" {
  source = "./modules/utils/reader"

  source_path = "${var.SRC_INFRA_PATH}/gcp/auto/cloud_scheduler/"
  enviroment  = var.ENVIRONMENT
  files_regex = "**"
  template_vars = {
    "__project_number__"          = var.PROJECT_NUMBER,
    "__project_name__"            = var.GCP_PROJECT,
    "__region__"                  = var.GCP_REGION,
    "__running_service_account__" = var.RUNNING_SERVICE_ACCOUNT,
    "__env__"                     = var.ENVIRONMENT,
    "__uid_now__"                 = var.UID_NOW,
    "__sha1__"                    = "__sha1__"
  }
}

module "gcp_cloud_scheduler" {
  for_each               = { for entry in local.scheduler : "${entry.source}" => entry }
  source                 = "./modules/gcp/cloud_scheduler"
  gcp_project            = var.GCP_PROJECT
  gcp_region             = lookup(each.value.content, "location", "") != "" ? lookup(each.value.content, "location") : var.GCP_REGION
  name                   = each.value.file_name
  attempt_deadline       = lookup(each.value.content, "attempt_deadline", "") != "" ? lookup(each.value.content, "attempt_deadline") : null
  description            = lookup(each.value.content, "description", "") != "" ? lookup(each.value.content, "description") : null
  paused                 = lookup(each.value.content, "paused", "") != "" ? lookup(each.value.content, "paused") : null
  schedule               = lookup(each.value.content, "schedule", "") != "" ? lookup(each.value.content, "schedule") : null
  time_zone              = lookup(each.value.content, "time_zone", "") != "" ? lookup(each.value.content, "time_zone") : null
  retry_config           = lookup(each.value.content, "retry_config", {}) != {} ? [lookup(each.value.content, "retry_config")] : []
  pubsub_target          = lookup(each.value.content, "pubsub_target", {}) != {} ? [lookup(each.value.content, "pubsub_target")] : []
  app_engine_http_target = lookup(each.value.content, "app_engine_http_target", {}) != {} ? [lookup(each.value.content, "app_engine_http_target")] : []
  http_target            = lookup(each.value.content, "http_target", {}) != {} ? [lookup(each.value.content, "http_target")] : []
  depends_on             = [module.gcp_apis_services, module.gcp_cloud_function, module.gcp_cloud_run]
}
