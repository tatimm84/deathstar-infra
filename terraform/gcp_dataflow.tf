# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# CLOUD RUN
# --------------------------------------------------------------------
locals {
  flow_files = module.json_flow_reader.parsed_data

  flow = [
    for item in local.flow_files : {
      file = item.source
      name = item.file_name
      content = jsondecode(templatefile(
        "${var.SRC_INFRA_PATH}/gcp/auto/dataflow/${item.source}",
        {
          "__project_number__" = var.PROJECT_NUMBER,
          "__project_name__"   = var.GCP_PROJECT,
          "__region__"         = var.GCP_REGION,
          "__env__"            = var.ENVIRONMENT,
          "__uid_now__"        = var.UID_NOW
        }
      ))
    }
  ]
}

module "json_flow_reader" {
  source = "./modules/utils/reader"

  source_path = "${var.SRC_INFRA_PATH}/gcp/auto/dataflow/"
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

module "gcp_dataflow" {
  for_each                     = { for entry in local.flow : "${entry.file}" => entry }
  source                       = "./modules/gcp/dataflow"
  gcp_project                  = var.GCP_PROJECT
  gcp_region                   = lookup(each.value.content, "location", "") != "" ? lookup(each.value.content, "location") : var.GCP_REGION
  gcp_zone                     = lookup(each.value.content, "zone", "") != "" ? lookup(each.value.content, "zone") : null
  name                         = each.value.name
  template_gcs_path            = lookup(each.value.content, "template_gcs_path", "") != "" ? lookup(each.value.content, "template_gcs_path") : null
  temp_gcs_region              = lookup(each.value.content, "temp_gcs_location", "") != "" ? lookup(each.value.content, "temp_gcs_location") : null
  parameters                   = lookup(each.value.content, "parameters", {}) != {} ? lookup(each.value.content, "parameters") : null
  labels                       = lookup(each.value.content, "labels", {}) != {} ? lookup(each.value.content, "labels") : null
  transform_name_mapping       = lookup(each.value.content, "transform_name_mapping", {}) != {} ? lookup(each.value.content, "transform_name_mapping") : null
  max_workers                  = lookup(each.value.content, "max_workers", "") != "" ? lookup(each.value.content, "max_workers") : null
  on_delete                    = lookup(each.value.content, "on_delete", "") != "" ? lookup(each.value.content, "on_delete") : null
  skip_wait_on_job_termination = lookup(each.value.content, "skip_wait_on_job_termination", "") != "" ? lookup(each.value.content, "skip_wait_on_job_termination") : null
  service_account_email        = lookup(each.value.content, "service_account_email", "") != "" ? lookup(each.value.content, "service_account_email") : null
  network                      = lookup(each.value.content, "network", "") != "" ? lookup(each.value.content, "network") : null
  subnetwork                   = lookup(each.value.content, "subnetwork", "") != "" ? lookup(each.value.content, "subnetwork") : null
  machine_type                 = lookup(each.value.content, "machine_type", "") != "" ? lookup(each.value.content, "machine_type") : null
  kms_key_name                 = lookup(each.value.content, "kms_key_name", "") != "" ? lookup(each.value.content, "kms_key_name") : null
  ip_configuration             = lookup(each.value.content, "ip_configuration", "") != "" ? lookup(each.value.content, "ip_configuration") : null
  additional_experiments       = lookup(each.value.content, "additional_experiments", "") != "" ? lookup(each.value.content, "additional_experiments") : null
  enable_streaming_engine      = lookup(each.value.content, "enable_streaming_engine", "") != "" ? lookup(each.value.content, "enable_streaming_engine") : null
  depends_on                   = [module.gcp_apis_services, module.gcp_cloud_storage_bucket]
}
