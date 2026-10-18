# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# CLOUD TASKS
# --------------------------------------------------------------------
locals {
  tasks = module.json_tasks_reader.parsed_data
}

module "json_tasks_reader" {
  source = "./modules/utils/reader"

  source_path = "${var.SRC_INFRA_PATH}/gcp/auto/tasks/"
  enviroment  = var.ENVIRONMENT
  files_regex = "**"
  template_vars = {
    "__project_number__" = var.PROJECT_NUMBER,
    "__env__"            = var.ENVIRONMENT,
    "__region__"         = var.GCP_REGION,
    "__zone__"           = "${var.GCP_REGION}-b",
    "__uid_now__"        = var.UID_NOW,
    "__project_name__"   = var.GCP_PROJECT
  }
}

module "gcp_tasks" {
  for_each                   = { for entry in local.tasks : "${entry.source}" => entry }
  source                     = "./modules/gcp/tasks"
  gcp_project                = lookup(each.value.content, "gcp_project", var.GCP_PROJECT)
  gcp_region                 = lookup(each.value.content, "gcp_region", var.GCP_REGION)
  queue_create               = lookup(each.value.content, "queue_create", true)
  queue_name                 = lookup(each.value.content, "queue_name", each.value.file_name)
  rate_limits                = lookup(each.value.content, "rate_limits", {}) != {} ? [lookup(each.value.content, "rate_limits")] : []
  retry_config               = lookup(each.value.content, "retry_config", {}) != {} ? [lookup(each.value.content, "retry_config")] : []
  stackdriver_logging_config = lookup(each.value.content, "stackdriver_logging_config", {}) != {} ? [lookup(each.value.content, "stackdriver_logging_config")] : []
  iam_members                = lookup(each.value.content, "iam_members", [])
  iam_member_role            = lookup(each.value.content, "iam_member_role", "roles/cloudtasks.enqueuer")
  depends_on                 = [module.gcp_apis_services]
}
