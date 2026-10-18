# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# SECRET MANAGER
# --------------------------------------------------------------------
locals {
  secret = module.json_secret_reader.parsed_data
}

module "json_secret_reader" {
  source = "./modules/utils/reader"

  source_path = "${var.SRC_INFRA_PATH}/gcp/auto/secret_manager/"
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

module "gcp_secret_manager" {
  for_each              = { for entry in local.secret : "${entry.source}" => entry }
  source                = "./modules/gcp/secret_manager"
  gcp_project           = var.GCP_PROJECT
  secret_create         = lookup(each.value.content, "secret_create", "") != "" ? lookup(each.value.content, "secret_create") : true
  secret_id             = each.value.file_name
  annotations           = lookup(each.value.content, "annotations", {}) != {} ? lookup(each.value.content, "annotations") : null
  expire_time           = lookup(each.value.content, "expire_time", "") != "" ? lookup(each.value.content, "expire_time") : null
  labels                = lookup(each.value.content, "labels", {}) != {} ? lookup(each.value.content, "labels") : null
  ttl                   = lookup(each.value.content, "ttl", "") != "" ? lookup(each.value.content, "ttl") : null
  version_aliases       = lookup(each.value.content, "version_aliases", "") != "" ? lookup(each.value.content, "version_aliases") : null
  replication           = lookup(each.value.content, "replication", {}) != {} ? [lookup(each.value.content, "replication")] : []
  rotation              = lookup(each.value.content, "rotation", {}) != {} ? [lookup(each.value.content, "rotation")] : []
  topics                = lookup(each.value.content, "topics", {}) != {} ? [lookup(each.value.content, "topics")] : []
  secret_path           = "projects/${var.GCP_PROJECT}/secrets/${each.value.file_name}"
  secret_data           = (lookup(each.value.content, "secret_data", null) != null ? jsonencode(lookup(each.value.content, "secret_data")) : null)
  enabled               = lookup(each.value.content, "enabled", "") != "" ? lookup(each.value.content, "enabled") : null
  deletion_policy       = lookup(each.value.content, "deletion_policy", "") != "" ? lookup(each.value.content, "deletion_policy") : null
  is_secret_data_base64 = lookup(each.value.content, "is_secret_data_base64", "") != "" ? lookup(each.value.content, "is_secret_data_base64") : null
  iam_members           = lookup(each.value.content, "iam_members", []) != [] ? lookup(each.value.content, "iam_members") : []
  iam_member_role       = lookup(each.value.content, "iam_member_role", "") != "" ? lookup(each.value.content, "iam_member_role") : null
  depends_on            = [module.gcp_apis_services]
}
