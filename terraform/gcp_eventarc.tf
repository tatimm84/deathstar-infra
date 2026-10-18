# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# EVENTARC
# --------------------------------------------------------------------
locals {
  eventarc = module.json_eventarc_reader.parsed_data
}

module "json_eventarc_reader" {
  source = "./modules/utils/reader"

  source_path = "${var.SRC_INFRA_PATH}/gcp/auto/eventarc/"
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


module "gcp_eventarc_trigger" {
  for_each                = { for entry in local.eventarc : "${entry.source}" => entry }
  source                  = "./modules/gcp/eventarc"
  gcp_project             = var.GCP_PROJECT
  gcp_region              = lookup(each.value.content, "location", "") != "" ? lookup(each.value.content, "location") : var.GCP_REGION
  name                    = each.value.file_name
  channel                 = lookup(each.value.content, "channel", "") != "" ? lookup(each.value.content, "channel") : null
  event_data_content_type = lookup(each.value.content, "event_data_content_type", "") != "" ? lookup(each.value.content, "event_data_content_type") : null
  labels                  = lookup(each.value.content, "labels", {}) != {} ? lookup(each.value.content, "labels") : null
  service_account         = lookup(each.value.content, "service_account", "") != "" ? lookup(each.value.content, "service_account") : null
  destination             = lookup(each.value.content, "destination", {}) != {} ? [lookup(each.value.content, "destination")] : []
  matching_criteria       = lookup(each.value.content, "matching_criteria")
  transport               = lookup(each.value.content, "transport", {}) != {} ? [lookup(each.value.content, "transport")] : []
  depends_on              = [module.gcp_apis_services, module.gcp_cloud_storage_bucket, module.gcp_cloud_run]
}
