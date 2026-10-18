# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# GCLOUD
# --------------------------------------------------------------------
locals {
  gcloud = module.json_gcloud_reader.parsed_data


  gcloud_old = distinct(flatten([
    for file in fileset("${var.SRC_INFRA_PATH}/gcp/auto/gcloud/", "*") : [{
      file      = file
      name      = replace("${split(".", file)[0]}", "__env__", var.ENVIRONMENT)
      sha1_json = filesha1("${var.SRC_INFRA_PATH}/gcp/auto/gcloud/${file}")
      content = templatefile(
        "${var.SRC_INFRA_PATH}/gcp/auto/gcloud/${file}",
        {
          "__project_number__" = var.PROJECT_NUMBER,
          "__project_name__"   = var.GCP_PROJECT,
          "__region__"         = var.GCP_REGION,
          "__env__"            = var.ENVIRONMENT,
          "__uid_now__"        = var.UID_NOW
        }
      )
    }]
  ]))
}

module "json_gcloud_reader" {
  source = "./modules/utils/reader"

  source_path = "${var.SRC_INFRA_PATH}/gcp/auto/gcloud/"
  enviroment  = var.ENVIRONMENT
  files_regex = "*"
  template_vars = {
    "__project_number__" = var.PROJECT_NUMBER,
    "__project_name__"   = var.GCP_PROJECT,
    "__region__"         = var.GCP_REGION,
    "__env__"            = var.ENVIRONMENT,
    "__uid_now__"        = var.UID_NOW
  }
}

module "gcp_gcloud" {
  for_each        = { for entry in local.gcloud : "${entry.source}" => entry }
  source          = "./modules/gcp/gcloud"
  gcp_project     = var.GCP_PROJECT
  cmd_instruction = lookup(each.value.content, "cmd_instruction", "") != "" ? lookup(each.value.content, "cmd_instruction") : null
  sha1_json       = each.value.sha1_json

  depends_on = [module.gcp_apis_services]
}
