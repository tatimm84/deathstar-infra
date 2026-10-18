# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# GCP PROJECT
# --------------------------------------------------------------------
variable "gcp_project" {
  type        = string
  description = "GCP project id"
}
variable "gcp_region" {
  type        = string
  description = "GCP region"
  default     = "us-central1"
}
variable "RUNNING_SERVICE_ACCOUNT" {
  type        = string
  description = "Service Account used to run the resources"
  default     = null
}
# --------------------------------------------------------------------
# BIGQUERY - DATASET
# --------------------------------------------------------------------
variable "dataset_create" {
  type        = bool
  description = "Bigquery dataset create"
  default     = true
}
variable "dataset_id" {
  type        = string
  description = "Bigquery dataset id"
}
variable "default_collation" {
  type        = string
  description = "Bigquery dataset default collation"
  default     = null
}
variable "default_partition_expiration_ms" {
  type        = number
  description = "Bigquery dataset default partition expiration in ms"
  default     = null
}
variable "default_table_expiration_ms" {
  type        = number
  description = "Bigquery dataset default table expiration in ms"
  default     = null
}
variable "delete_contents_on_destroy" {
  type        = bool
  description = "Bigquery dataset delete contents on destroy"
  default     = false
}
variable "description" {
  type        = string
  description = "Bigquery dataset description"
  default     = null
}
variable "friendly_name" {
  type        = string
  description = "Bigquery dataset friendly name"
  default     = null
}
variable "is_case_insensitive" {
  type        = bool
  description = "Bigquery dataset is case insensitive"
  default     = false
}
variable "labels" {
  type        = map(string)
  description = "Cloud run service labels"
  default     = null
}
variable "max_time_travel_hours" {
  type        = string
  description = "Bigquery dataset max time travel hours"
  default     = null
}
variable "storage_billing_model" {
  type        = string
  description = "Bigquery dataset storage billing model"
  default     = null
}
variable "access" {
  description = "Bigquery dataset access"
  default     = null
}
variable "external_dataset_reference" {
  description = "Bigquery dataset external dataset reference"
  default     = null
}
variable "default_encryption_configuration" {
  description = "Bigquery dataset encryption configuration"
  default     = null
}

# --------------------------------------------------------------------
# BIGQUERY - TABLE
# --------------------------------------------------------------------
variable "table_create" {
  type        = bool
  description = "Bigquery table create"
  default     = true
}
variable "table_id" {
  type        = string
  description = "Bigquery table id"
  default     = null
}
variable "clustering" {
  type        = list(string)
  description = "Bigquery table clustering"
  default     = null
}
variable "deletion_protection" {
  type        = bool
  description = "Bigquery table deletion protection"
  default     = null
}
variable "table_description" {
  type        = string
  description = "Bigquery table description"
  default     = null
}
variable "expiration_time" {
  type        = number
  description = "Bigquery table expiration time"
  default     = null
}
variable "table_friendly_name" {
  type        = string
  description = "Bigquery table friendly name"
  default     = null
}
variable "table_labels" {
  type        = map(string)
  description = "Bigquery table labels"
  default     = null
}
variable "max_staleness" {
  type        = string
  description = "Bigquery table max staleness"
  default     = null
}
variable "schema" {
  type        = string
  description = "Bigquery table schema"
  default     = null
}
variable "require_partition_filter" {
  type        = bool
  description = "Bigquery table require partition filter"
  default     = null
}
variable "encryption_configuration" {
  description = "Bigquery table encryption configuration"
  default     = null
}
variable "external_data_configuration" {
  description = "Bigquery table external data configuration"
  default     = null
}
variable "materialized_view" {
  description = "Bigquery table materialized view"
  default     = null
}
variable "materialized_view_query" {
  description = "Bigquery table materialized view query"
  default     = null
}
variable "table_replication_info" {
  description = "Bigquery table replication info"
  default     = null
}
variable "range_partitioning" {
  description = "Bigquery table range partitioning"
  default     = null
}
variable "table_constraints" {
  description = "Bigquery table constraints"
  default     = null
}
variable "time_partitioning" {
  description = "Bigquery table time partitioning"
  default     = null
}
variable "view" {
  description = "Bigquery table view"
  default     = null
}
variable "view_query" {
  description = "Bigquery table view query"
  default     = null
}

# --------------------------------------------------------------------
# BIGQUERY - DATA TRANSFER
# --------------------------------------------------------------------
variable "data_transfer_create" {
  type        = bool
  description = "Bigquery data transfer create"
  default     = false
}
variable "data_source_id" {
  type        = string
  description = "Bigquery data transfer data source id"
  default     = null
}
variable "display_name" {
  type        = string
  description = "Bigquery data transfer display name"
  default     = null
}
variable "data_refresh_window_days" {
  type        = number
  description = "Bigquery data transfer data refresh window days"
  default     = null
}
variable "destination_dataset_id" {
  type        = string
  description = "Bigquery data transfer destination dataset id"
  default     = null
}
variable "disabled" {
  type        = bool
  description = "Bigquery data transfer disabled"
  default     = null
}
variable "notification_pubsub_topic" {
  type        = string
  description = "Bigquery data transfer notification pubsub topic"
  default     = null
}
variable "params" {
  type        = map(string)
  description = "Bigquery data transfer params"
  default     = {}
}
variable "destination_table_id" {
  type        = string
  description = "Bigquery data transfer destination table id"
  default     = null
}
variable "query" {
  type        = string
  description = "Bigquery data transfer query"
  default     = null
}
variable "write_disposition" {
  type        = string
  description = "Bigquery data transfer write disposition"
  default     = null
}
variable "schedule" {
  type        = string
  description = "Bigquery data transfer schedule"
  default     = null
}
variable "service_account_name" {
  type        = string
  description = "Bigquery data transfer service account name"
  default     = null
}
variable "email_preferences" {
  description = "Bigquery data transfer email preferences"
  default     = null
}
variable "schedule_options" {
  description = "Bigquery data transfer schedule options"
  default     = null
}
variable "sensitive_params" {
  description = "Bigquery data transfer sensitive params"
  default     = null
}

# --------------------------------------------------------------------
# BIGQUERY - ROUTINE
# --------------------------------------------------------------------
variable "definition_body" {
  description = "Definition Body Routine"
  default     = null
}
variable "arguments_config" {
  type = list(object({
    name      = string
    data_type = any
  }))
  default = []
}

variable "routine_id" {
  description = "Routine ID"
  default     = null
}
variable "routine_type" {
  description = "Routine Type"
  default     = null
}
variable "language" {
  description = "Language Routine"
  default     = null
}
variable "routine_create" {
  type        = bool
  description = "Bigquery routine create"
  default     = true
}
variable "sql_query" {
  description = "Bigquery routine sql query"
  default     = null
}
