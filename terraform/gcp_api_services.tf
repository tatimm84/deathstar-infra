# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# APIS & SERVICES
# --------------------------------------------------------------------
locals {
  services_files = module.json_services_reader.parsed_data

  apis_services = distinct(flatten([
    for item in local.services_files : [
      for service in lookup(item.content, "services", []) : {
        file    = item.source
        service = service
        content = item.content
      }
    ]
  ]))
}

module "json_services_reader" {
  source = "./modules/utils/reader"

  source_path = "${var.SRC_INFRA_PATH}/gcp/auto/apis_services/"
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

module "gcp_apis_services_usage" {
  for_each                   = { for entry in local.apis_services : "${entry.file}_${entry.service}" => entry if "${entry.service}" == "serviceusage.googleapis.com" }
  source                     = "./modules/gcp/apis_services"
  gcp_project                = var.GCP_PROJECT
  service                    = each.value.service
  disable_dependent_services = lookup(each.value.content, "disable_dependent_services", "") != "" ? lookup(each.value.content, "disable_dependent_services") : null
  disable_on_destroy         = lookup(each.value.content, "disable_on_destroy", "") != "" ? lookup(each.value.content, "disable_on_destroy") : null
}

module "gcp_apis_services" {
  for_each                   = { for entry in local.apis_services : "${entry.file}_${entry.service}" => entry if "${entry.service}" != "serviceusage.googleapis.com" }
  source                     = "./modules/gcp/apis_services"
  gcp_project                = var.GCP_PROJECT
  service                    = each.value.service
  disable_dependent_services = lookup(each.value.content, "disable_dependent_services", "") != "" ? lookup(each.value.content, "disable_dependent_services") : null
  disable_on_destroy         = lookup(each.value.content, "disable_on_destroy", "") != "" ? lookup(each.value.content, "disable_on_destroy") : null
  depends_on                 = [module.gcp_apis_services_usage]
}
