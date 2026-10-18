# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# CLOUD RUN
# --------------------------------------------------------------------
locals {
  run_files = module.json_run_reader.parsed_data

  run = [
    for item in local.run_files : {
      file = item.source
      name = item.file_name
      content = jsondecode(templatefile(
        "${var.SRC_INFRA_PATH}/gcp/auto/cloud_run/${item.source}",
        {
          "__project_number__"          = var.PROJECT_NUMBER,
          "__project_name__"            = var.GCP_PROJECT,
          "__region__"                  = var.GCP_REGION,
          "__running_service_account__" = var.RUNNING_SERVICE_ACCOUNT,
          "__env__"                     = var.ENVIRONMENT,
          "__uid_now__"                 = var.UID_NOW,
          "__sha1__" = sha1(join("", [
            for f in fileset(lookup(item.content, "image_path", "${var.SRC_CODE_PATH}/${item.file_name}"), "**") :
            filesha1("${lookup(item.content, "image_path", "${var.SRC_CODE_PATH}/${item.file_name}")}/${f}")
          ]))
        }
      ))
    }
  ]
}

module "json_run_reader" {
  source = "./modules/utils/reader"

  source_path = "${var.SRC_INFRA_PATH}/gcp/auto/cloud_run/"
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

module "gcp_cloud_run" {
  for_each             = { for entry in local.run : "${entry.file}" => entry }
  source               = "./modules/gcp/cloud_run"
  gcp_project          = var.GCP_PROJECT
  gcp_region           = lookup(each.value.content, "location", "") != "" ? lookup(each.value.content, "location") : var.GCP_REGION
  cloud_run_type       = lookup(each.value.content, "cloud_run_type", "") != "" ? lookup(each.value.content, "cloud_run_type") : null
  name                 = each.value.name
  annotations          = lookup(each.value.content, "annotations", {}) != {} ? lookup(each.value.content, "annotations") : null
  client               = lookup(each.value.content, "client", "") != "" ? lookup(each.value.content, "client") : null
  client_version       = lookup(each.value.content, "client_version", "") != "" ? lookup(each.value.content, "client_version") : null
  custom_audiences     = lookup(each.value.content, "custom_audiences", []) != [] ? lookup(each.value.content, "custom_audiences") : []
  description          = lookup(each.value.content, "description", "") != "" ? lookup(each.value.content, "description") : null
  ingress              = lookup(each.value.content, "ingress", "") != "" ? lookup(each.value.content, "ingress") : null
  labels               = lookup(each.value.content, "labels", {}) != {} ? lookup(each.value.content, "labels") : null
  launch_stage         = lookup(each.value.content, "launch_stage", "") != "" ? lookup(each.value.content, "launch_stage") : null
  binary_authorization = lookup(each.value.content, "binary_authorization", {}) != {} ? [lookup(each.value.content, "binary_authorization")] : []
  traffic              = lookup(each.value.content, "traffic", {}) != {} ? [lookup(each.value.content, "traffic")] : []
  template             = lookup(each.value.content, "template", {}) != {} ? [lookup(each.value.content, "template")] : []
  iam_type             = lookup(each.value.content, "iam_type", "") != "" ? lookup(each.value.content, "iam_type") : null
  iam_member           = lookup(each.value.content, "iam_member", "") != "" ? lookup(each.value.content, "iam_member") : null
  iam_members          = lookup(each.value.content, "iam_members", []) != [] ? lookup(each.value.content, "iam_members") : null
  iam_condition        = lookup(each.value.content, "iam_condition", []) != [] ? lookup(each.value.content, "iam_condition") : []
  depends_on           = [module.gcp_apis_services, module.gcp_artifact_registry_image]
}
