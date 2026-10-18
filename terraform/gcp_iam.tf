# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# IAM
# --------------------------------------------------------------------
locals {
  sa = module.json_sa_reader.parsed_data

  iam_reader = module.json_roles_reader.parsed_data
  iam = distinct(flatten([
    for item in local.iam_reader : [
      for role in lookup(item.content, "iam_role") : {
        file = item.source
        role = role
        name = item.file_name
        content = jsondecode(templatefile(
          "${var.SRC_INFRA_PATH}/gcp/auto/iam/${item.source}",
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
  ]))
}


module "json_sa_reader" {
  source = "./modules/utils/reader"

  source_path = "${var.SRC_INFRA_PATH}/gcp/auto/iam/"
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

module "json_roles_reader" {
  source = "./modules/utils/reader"

  source_path = "${var.SRC_INFRA_PATH}/gcp/auto/iam/"
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

module "gcp_iam_sa" {
  for_each                     = { for entry in local.sa : "${entry.source}" => entry }
  source                       = "./modules/gcp/iam"
  gcp_project                  = var.GCP_PROJECT
  gcp_region                   = lookup(each.value.content, "location", "") != "" ? lookup(each.value.content, "location") : var.GCP_REGION
  sa_create                    = lookup(each.value.content, "sa_create", "") != "" ? lookup(each.value.content, "sa_create") : true
  service_account_id           = each.value.file_name
  create_ignore_already_exists = lookup(each.value.content, "create_ignore_already_exists", "") != "" ? title(lookup(each.value.content, "create_ignore_already_exists", "")) : null
  display_name                 = lookup(each.value.content, "display_name", "") != "" ? title(lookup(each.value.content, "display_name", "")) : null
  sa_description               = lookup(each.value.content, "sa_description", "") != "" ? lookup(each.value.content, "sa_description") : null
  disabled                     = lookup(each.value.content, "disabled", "") != "" ? lookup(each.value.content, "disabled") : null
  depends_on                   = [module.gcp_apis_services]
}

module "gcp_iam_role" {
  for_each         = { for entry in local.iam : "${entry.file}_${entry.role}" => entry }
  source           = "./modules/gcp/iam"
  gcp_project      = var.GCP_PROJECT
  gcp_region       = lookup(each.value.content, "location", "") != "" ? lookup(each.value.content, "location") : var.GCP_REGION
  sa_create        = false
  iam_type         = lookup(each.value.content, "iam_type", "") != "" ? lookup(each.value.content, "iam_type") : null
  iam_role         = each.value.role
  iam_member       = lookup(each.value.content, "iam_member", "") != "" ? lookup(each.value.content, "iam_member") : null
  iam_members      = lookup(each.value.content, "iam_members", []) != [] ? lookup(each.value.content, "iam_members") : null
  service          = lookup(each.value.content, "service", "") != "" ? lookup(each.value.content, "service") : null
  iam_condition    = lookup(each.value.content, "iam_condition", {}) != {} ? [lookup(each.value.content, "iam_condition")] : []
  audit_log_config = try(each.value.content["audit_log_config"], {}) != {} ? each.value.content["audit_log_config"] : []
  depends_on       = [module.gcp_iam_sa]
}
