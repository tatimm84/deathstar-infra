# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# BIGQUERY
# --------------------------------------------------------------------
locals {
  dataset = module.json_datasets_reader.parsed_data

  table_files = module.json_tables_reader.parsed_data
  table = [
    for item in local.table_files : {
      file       = item.source
      dataset_id = item.path_name
      table_id   = item.file_name
      content    = item.content
      query = try(
        templatefile(
          "${var.SRC_INFRA_PATH}/gcp/auto/bigquery/${replace(item.full_name, ".json", ".sql")}",
          {
            "__project_number__"          = var.PROJECT_NUMBER,
            "__project_name__"            = var.GCP_PROJECT,
            "__region__"                  = var.GCP_REGION,
            "__env__"                     = var.ENVIRONMENT,
            "__uid_now__"                 = var.UID_NOW,
            "__running_service_account__" = var.RUNNING_SERVICE_ACCOUNT
          }
        ),
        null
      )
    }
  ]

  routines_files = module.json_routines_reader.parsed_data
  routines = [
    for item in local.routines_files : {
      file       = item.source
      dataset_id = item.path_name
      table_id   = item.file_name
      content    = item.content
      query = try(
        templatefile(
          "${var.SRC_INFRA_PATH}/gcp/auto/bigquery/${replace(item.full_name, ".json", ".sql")}",
          {
            "__project_number__"          = var.PROJECT_NUMBER,
            "__project_name__"            = var.GCP_PROJECT,
            "__region__"                  = var.GCP_REGION,
            "__running_service_account__" = var.RUNNING_SERVICE_ACCOUNT,
            "__env__"                     = var.ENVIRONMENT,
            "__uid_now__"                 = var.UID_NOW
          }
        ),
        null
      )
    }
  ]

}

module "json_datasets_reader" {
  source = "./modules/utils/reader"

  source_path = "${var.SRC_INFRA_PATH}/gcp/auto/bigquery/"
  enviroment  = var.ENVIRONMENT
  files_regex = "*"
  template_vars = {
    "__project_number__"          = var.PROJECT_NUMBER,
    "__project_name__"            = var.GCP_PROJECT,
    "__region__"                  = var.GCP_REGION,
    "__running_service_account__" = var.RUNNING_SERVICE_ACCOUNT,
    "__env__"                     = var.ENVIRONMENT,
    "__uid_now__"                 = var.UID_NOW

  }
}

module "json_tables_reader" {
  source = "./modules/utils/reader"

  source_path = "${var.SRC_INFRA_PATH}/gcp/auto/bigquery/"
  enviroment  = var.ENVIRONMENT
  files_regex = "[^.]**/[^.]*.json"
  template_vars = {
    "__project_number__"          = var.PROJECT_NUMBER,
    "__project_name__"            = var.GCP_PROJECT,
    "__region__"                  = var.GCP_REGION,
    "__running_service_account__" = var.RUNNING_SERVICE_ACCOUNT,
    "__env__"                     = var.ENVIRONMENT,
    "__uid_now__"                 = var.UID_NOW
  }
}

module "json_routines_reader" {
  source = "./modules/utils/reader"

  source_path = "${var.SRC_INFRA_PATH}/gcp/auto/bigquery/"
  enviroment  = var.ENVIRONMENT
  files_regex = "[^.]**/routines/[^.]*.json"
  template_vars = {
    "__project_number__"          = var.PROJECT_NUMBER,
    "__project_name__"            = var.GCP_PROJECT,
    "__region__"                  = var.GCP_REGION,
    "__running_service_account__" = var.RUNNING_SERVICE_ACCOUNT,
    "__env__"                     = var.ENVIRONMENT,
    "__uid_now__"                 = var.UID_NOW
  }
}

module "gcp_bigquery_dataset" {
  for_each                         = { for entry in local.dataset : "${entry.source}" => entry }
  source                           = "./modules/gcp/bigquery"
  gcp_project                      = var.GCP_PROJECT
  gcp_region                       = lookup(each.value.content, "location", "") != "" ? lookup(each.value.content, "location") : var.GCP_REGION
  dataset_create                   = true
  dataset_id                       = lookup(each.value.content, "dataset_id", "") != "" ? lookup(each.value.content, "dataset_id") : "${each.value.file_name}"
  default_collation                = lookup(each.value.content, "default_collation", "") != "" ? lookup(each.value.content, "default_collation") : null
  default_partition_expiration_ms  = lookup(each.value.content, "default_partition_expiration_ms", "") != "" ? lookup(each.value.content, "default_partition_expiration_ms") : null
  default_table_expiration_ms      = lookup(each.value.content, "default_table_expiration_ms", "") != "" ? lookup(each.value.content, "default_table_expiration_ms") : null
  delete_contents_on_destroy       = lookup(each.value.content, "delete_contents_on_destroy", "") != "" ? lookup(each.value.content, "delete_contents_on_destroy") : false
  description                      = lookup(each.value.content, "description", "") != "" ? lookup(each.value.content, "description") : null
  friendly_name                    = lookup(each.value.content, "friendly_name", "") != "" ? lookup(each.value.content, "friendly_name") : null
  is_case_insensitive              = lookup(each.value.content, "is_case_insensitive", "") != "" ? lookup(each.value.content, "is_case_insensitive") : null
  labels                           = lookup(each.value.content, "labels", {}) != {} ? lookup(each.value.content, "labels") : null
  max_time_travel_hours            = lookup(each.value.content, "max_time_travel_hours", "") != "" ? lookup(each.value.content, "max_time_travel_hours") : null
  storage_billing_model            = lookup(each.value.content, "storage_billing_model", "") != "" ? lookup(each.value.content, "storage_billing_model") : null
  access                           = lookup(each.value.content, "access", {}) != {} ? [lookup(each.value.content, "access")] : []
  default_encryption_configuration = lookup(each.value.content, "default_encryption_configuration", {}) != {} ? [lookup(each.value.content, "default_encryption_configuration")] : []
  external_dataset_reference       = lookup(each.value.content, "external_dataset_reference", {}) != {} ? [lookup(each.value.content, "external_dataset_reference")] : []
  table_create                     = false
  data_transfer_create             = false
  routine_create                   = false
  depends_on                       = [module.gcp_apis_services]
}

module "gcp_bigquery_table" {
  for_each                    = { for entry in local.table : "${entry.file}" => entry }
  source                      = "./modules/gcp/bigquery"
  gcp_project                 = var.GCP_PROJECT
  gcp_region                  = lookup(each.value.content, "location", "") != "" ? lookup(each.value.content, "location") : var.GCP_REGION
  dataset_create              = false
  routine_create              = false
  table_create                = lookup(each.value.content, "table_create", "") != "" ? lookup(each.value.content, "table_create") : true
  dataset_id                  = lookup(each.value.content, "dataset_id", "") != "" ? lookup(each.value.content, "dataset_id") : "${each.value.dataset_id}"
  table_id                    = lookup(each.value.content, "table_id", "") != "" ? lookup(each.value.content, "table_id") : "${each.value.table_id}"
  clustering                  = lookup(each.value.content, "clustering", []) != [] ? lookup(each.value.content, "clustering") : null
  deletion_protection         = lookup(each.value.content, "deletion_protection", "") != "" ? lookup(each.value.content, "deletion_protection") : null
  table_description           = lookup(each.value.content, "description", "") != "" ? lookup(each.value.content, "description") : null
  expiration_time             = lookup(each.value.content, "expiration_time", "") != "" ? lookup(each.value.content, "expiration_time") : null
  table_friendly_name         = lookup(each.value.content, "friendly_name", "") != "" ? lookup(each.value.content, "friendly_name") : null
  table_labels                = lookup(each.value.content, "labels", {}) != {} ? lookup(each.value.content, "labels") : null
  max_staleness               = lookup(each.value.content, "max_staleness", {}) != {} ? lookup(each.value.content, "max_staleness") : null
  schema                      = lookup(each.value.content, "schema", null) != null ? jsonencode(lookup(each.value.content, "schema")) : null
  require_partition_filter    = lookup(each.value.content, "require_partition_filter", "") != "" ? lookup(each.value.content, "require_partition_filter") : null
  encryption_configuration    = lookup(each.value.content, "encryption_configuration", {}) != {} ? [lookup(each.value.content, "encryption_configuration")] : []
  external_data_configuration = lookup(each.value.content, "external_data_configuration", {}) != {} ? [lookup(each.value.content, "external_data_configuration")] : []
  materialized_view           = lookup(each.value.content, "materialized_view", {}) != {} ? [lookup(each.value.content, "materialized_view")] : []
  materialized_view_query     = lookup(each.value.content, "materialized_view", {}) != {} ? "${each.value.query}" : null
  range_partitioning          = lookup(each.value.content, "range_partitioning", {}) != {} ? [lookup(each.value.content, "range_partitioning")] : []
  table_constraints           = lookup(each.value.content, "table_constraints", {}) != {} ? [lookup(each.value.content, "table_constraints")] : []
  table_replication_info      = lookup(each.value.content, "table_replication_info", {}) != {} ? [lookup(each.value.content, "table_replication_info")] : []
  time_partitioning           = lookup(each.value.content, "time_partitioning", {}) != {} ? [lookup(each.value.content, "time_partitioning")] : []
  view                        = lookup(each.value.content, "view", {}) != {} ? [lookup(each.value.content, "view")] : []
  view_query                  = lookup(each.value.content, "view", {}) != {} ? "${each.value.query}" : null
  data_transfer_create        = lookup(each.value.content, "data_transfer_create", {}) != {} ? lookup(each.value.content, "data_transfer_create") : false
  data_source_id              = lookup(each.value.content, "data_source_id", "") != "" ? lookup(each.value.content, "data_source_id") : null
  display_name                = lookup(each.value.content, "display_name", "") != "" ? lookup(each.value.content, "display_name") : "${substr(lookup(each.value.content, "data_source_id", ""), 0, 3)}_${replace(split(".", each.value.file)[0], "/", "_")}"
  data_refresh_window_days    = lookup(each.value.content, "data_refresh_window_days", "") != "" ? lookup(each.value.content, "data_refresh_window_days") : null
  destination_dataset_id      = lookup(each.value.content, "define_dataset", true) ? lookup(each.value.content, "dataset_id", "") != "" ? lookup(each.value.content, "dataset_id") : "${each.value.dataset_id}" : null
  disabled                    = lookup(each.value.content, "disabled", "") != "" ? lookup(each.value.content, "disabled") : null
  notification_pubsub_topic   = lookup(each.value.content, "notification_pubsub_topic", "") != "" ? lookup(each.value.content, "notification_pubsub_topic") : null
  params                      = lookup(each.value.content, "params", "") != "" ? lookup(each.value.content, "params") : {}
  destination_table_id        = lookup(each.value.content, "define_table", true) ? lookup(each.value.content, "table_id", "") != "" ? lookup(each.value.content, "table_id") : "${each.value.table_id}" : null
  query                       = lookup(each.value.content, "data_transfer_create", {}) != {} ? "${each.value.query}" : null
  write_disposition           = lookup(each.value.content, "write_disposition", null)
  schedule                    = lookup(each.value.content, "schedule", "") != "" ? lookup(each.value.content, "schedule") : null
  service_account_name        = lookup(each.value.content, "service_account_name", "") != "" ? lookup(each.value.content, "service_account_name") : null
  email_preferences           = lookup(each.value.content, "email_preferences", {}) != {} ? [lookup(each.value.content, "email_preferences")] : []
  schedule_options            = lookup(each.value.content, "schedule_options", {}) != {} ? [lookup(each.value.content, "schedule_options")] : []
  sensitive_params            = lookup(each.value.content, "sensitive_params", {}) != {} ? [lookup(each.value.content, "sensitive_params")] : []
  depends_on                  = [module.gcp_bigquery_dataset]
}

module "gcp_bigquery_routine" {
  for_each             = { for entry in local.routines : entry.file => entry }
  source               = "./modules/gcp/bigquery"
  gcp_project          = var.GCP_PROJECT
  routine_create       = true
  table_create         = false
  dataset_create       = false
  data_transfer_create = false
  dataset_id           = each.value.dataset_id
  routine_id           = lookup(each.value.content, "routine_id", each.value.table_id)
  definition_body      = lookup(each.value.content, "definition_body", each.value.query)
  arguments_config     = lookup(each.value.content, "arguments_config", null)
  routine_type         = lookup(each.value.content, "routine_type", null)
  language             = lookup(each.value.content, "language", null)

  depends_on = [module.gcp_bigquery_dataset]
}
