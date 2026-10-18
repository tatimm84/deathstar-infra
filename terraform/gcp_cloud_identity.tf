# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# CLOUD IDENTITY
# --------------------------------------------------------------------
locals {
  identity = module.json_identity_reader.parsed_data
}

module "json_identity_reader" {
  source = "./modules/utils/reader"

  source_path = "${var.SRC_INFRA_PATH}/gcp/auto/cloud_identity/"
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

module "gcp_cloud_identity" {
  for_each             = { for entry in local.identity : "${entry.source}" => entry }
  source               = "./modules/gcp/cloud_identity"
  parent               = lookup(each.value.content, "parent", "") != "" ? lookup(each.value.content, "parent") : null
  display_name         = lookup(each.value.content, "display_name", "") != "" ? lookup(each.value.content, "display_name") : null
  description          = lookup(each.value.content, "description", "") != "" ? lookup(each.value.content, "description") : null
  initial_group_config = lookup(each.value.content, "initial_group_config", "") != "" ? lookup(each.value.content, "initial_group_config") : null
  labels               = lookup(each.value.content, "labels", {}) != {} ? lookup(each.value.content, "labels") : null
  group_key            = lookup(each.value.content, "group_key", {}) != {} ? [lookup(each.value.content, "group_key")] : []
  group                = lookup(each.value.content, "group", "") != "" ? lookup(each.value.content, "group") : null
  member_key           = lookup(each.value.content, "member_key", {}) != {} ? [lookup(each.value.content, "member_key")] : []
  preferred_member_key = lookup(each.value.content, "preferred_member_key", {}) != {} ? [lookup(each.value.content, "preferred_member_key")] : []
  roles                = lookup(each.value.content, "roles", {}) != {} ? [lookup(each.value.content, "roles")] : []
  # depends_on           = [ module.gcp_apis_services ]
}
