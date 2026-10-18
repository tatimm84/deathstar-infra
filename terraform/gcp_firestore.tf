# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# FIRESTORE
# --------------------------------------------------------------------
locals {
  database   = module.json_database_reader.parsed_data
  collection = module.json_collection_reader.parsed_data
}

module "json_database_reader" {
  source = "./modules/utils/reader"

  source_path = "${var.SRC_INFRA_PATH}/gcp/auto/firestore/"
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

module "json_collection_reader" {
  source = "./modules/utils/reader"

  source_path = "${var.SRC_INFRA_PATH}/gcp/auto/firestore/"
  enviroment  = var.ENVIRONMENT
  files_regex = "[^.]**/[^.]*.json"
  template_vars = {
    "__project_number__" = var.PROJECT_NUMBER,
    "__project_name__"   = var.GCP_PROJECT,
    "__region__"         = var.GCP_REGION,
    "__env__"            = var.ENVIRONMENT,
    "__uid_now__"        = var.UID_NOW
  }
}

module "gcp_firestore_database" {
  for_each                          = { for entry in local.database : "${entry.source}" => entry }
  source                            = "./modules/gcp/firestore"
  gcp_project                       = var.GCP_PROJECT
  gcp_region                        = lookup(each.value.content, "location", "") != "" ? lookup(each.value.content, "location") : var.GCP_REGION
  database_create                   = true
  database                          = each.value.file_name
  type                              = lookup(each.value.content, "type", "") != "" ? lookup(each.value.content, "type") : null
  concurrency_mode                  = lookup(each.value.content, "concurrency_mode", "") != "" ? lookup(each.value.content, "concurrency_mode") : null
  app_engine_integration_mode       = lookup(each.value.content, "app_engine_integration_mode", "") != "" ? lookup(each.value.content, "app_engine_integration_mode") : null
  point_in_time_recovery_enablement = lookup(each.value.content, "point_in_time_recovery_enablement", "") != "" ? lookup(each.value.content, "point_in_time_recovery_enablement") : null
  delete_protection_state           = lookup(each.value.content, "delete_protection_state", "") != "" ? lookup(each.value.content, "delete_protection_state") : null
  deletion_policy                   = lookup(each.value.content, "deletion_policy", "") != "" ? lookup(each.value.content, "deletion_policy") : null
  depends_on                        = [module.gcp_apis_services]
}
module "gcp_firestore_collection" {
  for_each        = { for entry in local.collection : "${entry.source}" => entry }
  source          = "./modules/gcp/firestore"
  gcp_project     = var.GCP_PROJECT
  gcp_region      = lookup(each.value.content, "location", "") != "" ? lookup(each.value.content, "location") : var.GCP_REGION
  database_create = false
  database        = each.value.path_name
  collection      = each.value.file_name
  api_scope       = lookup(each.value.content, "api_scope", "") != "" ? lookup(each.value.content, "api_scope") : null
  query_scope     = lookup(each.value.content, "query_scope", "") != "" ? lookup(each.value.content, "query_scope") : null
  index_fields    = lookup(each.value.content, "index_fields", []) != [] ? lookup(each.value.content, "index_fields") : null
  document_id     = lookup(each.value.content, "document_id", "") != "" ? lookup(each.value.content, "document_id") : null
  document_fields = (lookup(each.value.content, "document_fields", null) != null ? jsonencode(lookup(each.value.content, "document_fields")) : null)
  depends_on      = [module.gcp_firestore_database]
}
