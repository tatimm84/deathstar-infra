# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# BIGQUERY - DATASET
# --------------------------------------------------------------------
resource "google_bigquery_dataset" "dataset" {
  count                           = var.dataset_create ? 1 : 0
  project                         = var.gcp_project
  location                        = var.gcp_region
  dataset_id                      = var.dataset_id
  default_collation               = var.default_collation
  default_partition_expiration_ms = var.default_partition_expiration_ms
  default_table_expiration_ms     = var.default_table_expiration_ms
  delete_contents_on_destroy      = var.delete_contents_on_destroy
  description                     = var.description
  friendly_name                   = var.friendly_name
  is_case_insensitive             = var.is_case_insensitive
  labels                          = var.labels
  max_time_travel_hours           = var.max_time_travel_hours
  storage_billing_model           = var.storage_billing_model

  dynamic "access" {
    for_each = var.access
    content {
      domain         = lookup(access.value, "domain", null)
      group_by_email = lookup(access.value, "group_by_email", null)
      role           = lookup(access.value, "role", null)
      special_group  = lookup(access.value, "special_group", null)
      iam_member     = lookup(access.value, "iam_member", null)
      user_by_email  = lookup(access.value, "user_by_email", null)
      dynamic "dataset" {
        for_each = lookup(access.value, "dataset", {}) != {} ? [lookup(access.value, "dataset")] : []
        content {
          target_types = lookup(dataset.value, "target_types", null)
          dynamic "dataset" {
            for_each = lookup(dataset.value, "dataset", {}) != {} ? [lookup(dataset.value, "dataset")] : []
            content {
              project_id = lookup(dataset.value, "project_id", null)
              dataset_id = lookup(dataset.value, "dataset_id", null)
            }
          }
        }
      }
      dynamic "routine" {
        for_each = lookup(access.value, "routine", {}) != {} ? [lookup(access.value, "routine")] : []
        content {
          project_id = lookup(routine.value, "project_id", null)
          dataset_id = lookup(routine.value, "dataset_id", null)
          routine_id = lookup(routine.value, "dataset_id", null)
        }
      }
      dynamic "view" {
        for_each = lookup(access.value, "view", {}) != {} ? [lookup(access.value, "view")] : []
        content {
          project_id = lookup(view.value, "project_id", null)
          dataset_id = lookup(view.value, "dataset_id", null)
          table_id   = lookup(view.value, "table_id", null)
        }
      }
    }
  }
  dynamic "default_encryption_configuration" {
    for_each = var.default_encryption_configuration
    content {
      kms_key_name = lookup(default_encryption_configuration.value, "kms_key_name", null)
    }
  }
}

# --------------------------------------------------------------------
# BIGQUERY - TABLE
# --------------------------------------------------------------------
resource "google_bigquery_table" "table" {
  count                    = var.table_create ? 1 : 0
  project                  = var.gcp_project
  dataset_id               = var.dataset_id
  table_id                 = var.table_id
  clustering               = var.clustering
  deletion_protection      = var.deletion_protection
  description              = var.table_description
  expiration_time          = var.expiration_time
  friendly_name            = var.table_friendly_name
  labels                   = var.table_labels
  max_staleness            = var.max_staleness
  schema                   = length(var.materialized_view) > 0 ? null : var.schema
  require_partition_filter = var.require_partition_filter
  depends_on               = [google_bigquery_dataset.dataset]

  dynamic "encryption_configuration" {
    for_each = var.encryption_configuration
    content {
      kms_key_name = lookup(encryption_configuration.value, "kms_key_name", null)
    }
  }
  dynamic "external_data_configuration" {
    for_each = var.external_data_configuration
    content {
      autodetect                = lookup(external_data_configuration.value, "autodetect", null)
      compression               = lookup(external_data_configuration.value, "compression", null)
      connection_id             = lookup(external_data_configuration.value, "connection_id", null)
      file_set_spec_type        = lookup(external_data_configuration.value, "file_set_spec_type", null)
      ignore_unknown_values     = lookup(external_data_configuration.value, "ignore_unknown_values", null)
      json_extension            = lookup(external_data_configuration.value, "json_extension", null)
      max_bad_records           = lookup(external_data_configuration.value, "max_bad_records", null)
      metadata_cache_mode       = lookup(external_data_configuration.value, "metadata_cache_mode", null)
      object_metadata           = lookup(external_data_configuration.value, "object_metadata", null)
      reference_file_schema_uri = lookup(external_data_configuration.value, "reference_file_schema_uri", null)
      schema                    = lookup(external_data_configuration.value, "schema", null)
      source_format             = lookup(external_data_configuration.value, "source_format", null)
      source_uris               = lookup(external_data_configuration.value, "source_uris", null)
      dynamic "avro_options" {
        for_each = lookup(external_data_configuration.value, "avro_options", {}) != {} ? [lookup(external_data_configuration.value, "avro_options")] : []
        content {
          use_avro_logical_types = lookup(avro_options.value, "use_avro_logical_types", null)
        }
      }
      dynamic "csv_options" {
        for_each = lookup(external_data_configuration.value, "csv_options", {}) != {} ? [lookup(external_data_configuration.value, "csv_options")] : []
        content {
          allow_jagged_rows     = lookup(csv_options.value, "allow_jagged_rows", null)
          allow_quoted_newlines = lookup(csv_options.value, "allow_quoted_newlines", null)
          encoding              = lookup(csv_options.value, "encoding", null)
          field_delimiter       = lookup(csv_options.value, "field_delimiter", null)
          quote                 = lookup(csv_options.value, "quote", null)
          skip_leading_rows     = lookup(csv_options.value, "skip_leading_rows", null)
        }
      }
      dynamic "google_sheets_options" {
        for_each = lookup(external_data_configuration.value, "google_sheets_options", {}) != {} ? [lookup(external_data_configuration.value, "google_sheets_options")] : []
        content {
          range             = lookup(google_sheets_options.value, "range", null)
          skip_leading_rows = lookup(google_sheets_options.value, "skip_leading_rows", null)
        }
      }
      dynamic "json_options" {
        for_each = lookup(external_data_configuration.value, "json_options", {}) != {} ? [lookup(external_data_configuration.value, "json_options")] : []
        content {
          encoding = lookup(json_options.value, "encoding", null)
        }
      }
      dynamic "hive_partitioning_options" {
        for_each = lookup(external_data_configuration.value, "hive_partitioning_options", {}) != {} ? [lookup(external_data_configuration.value, "hive_partitioning_options")] : []
        content {
          mode                     = lookup(hive_partitioning_options.value, "mode", null)
          require_partition_filter = lookup(hive_partitioning_options.value, "require_partition_filter", null)
          source_uri_prefix        = lookup(hive_partitioning_options.value, "source_uri_prefix", null)
        }
      }
      dynamic "parquet_options" {
        for_each = lookup(external_data_configuration.value, "parquet_options", {}) != {} ? [lookup(external_data_configuration.value, "parquet_options")] : []
        content {
          enum_as_string        = lookup(parquet_options.value, "enum_as_string", null)
          enable_list_inference = lookup(parquet_options.value, "enable_list_inference", null)
        }
      }
    }
  }
  dynamic "materialized_view" {
    for_each = var.materialized_view
    content {
      allow_non_incremental_definition = lookup(materialized_view.value, "allow_non_incremental_definition", null)
      enable_refresh                   = lookup(materialized_view.value, "enable_refresh", null)
      query                            = lookup(materialized_view.value, "query", var.materialized_view_query)
      refresh_interval_ms              = lookup(materialized_view.value, "refresh_interval_ms", null)
    }
  }
  dynamic "table_replication_info" {
    for_each = var.table_replication_info
    content {
      source_project_id       = lookup(table_replication_info.value, "source_project_id", null)
      source_dataset_id       = lookup(table_replication_info.value, "source_dataset_id", null)
      source_table_id         = lookup(table_replication_info.value, "source_table_id", null)
      replication_interval_ms = lookup(table_replication_info.value, "replication_interval_ms", null)
    }
  }
  dynamic "range_partitioning" {
    for_each = var.range_partitioning
    content {
      field = lookup(range_partitioning.value, "field", null)
      dynamic "range" {
        for_each = lookup(range_partitioning.value, "range", {}) != {} ? [lookup(range_partitioning.value, "range")] : []
        content {
          start    = lookup(range.value, "start", null)
          end      = lookup(range.value, "end", null)
          interval = lookup(range.value, "interval", null)
        }
      }
    }
  }
  dynamic "table_constraints" {
    for_each = var.table_constraints
    content {
      dynamic "primary_key" {
        for_each = lookup(table_constraints.value, "primary_key", {}) != {} ? [lookup(table_constraints.value, "primary_key")] : []
        content {
          columns = lookup(primary_key.value, "columns", null)
        }
      }
      dynamic "foreign_keys" {
        for_each = lookup(table_constraints.value, "foreign_keys", {}) != {} ? [lookup(table_constraints.value, "foreign_keys")] : []
        content {
          name = lookup(foreign_keys.value, "name", null)
          dynamic "referenced_table" {
            for_each = lookup(foreign_keys.value, "referenced_table", {}) != {} ? [lookup(foreign_keys.value, "referenced_table")] : []
            content {
              project_id = lookup(referenced_table.value, "project_id", null)
              dataset_id = lookup(referenced_table.value, "dataset_id", null)
              table_id   = lookup(referenced_table.value, "table_id", null)
            }
          }
          dynamic "column_references" {
            for_each = lookup(foreign_keys.value, "column_references", {}) != {} ? [lookup(foreign_keys.value, "column_references")] : []
            content {
              referencing_column = lookup(column_references.value, "referencing_column", null)
              referenced_column  = lookup(column_references.value, "referenced_column", null)
            }
          }
        }
      }
    }
  }
  dynamic "time_partitioning" {
    for_each = var.time_partitioning
    content {
      expiration_ms = lookup(time_partitioning.value, "expiration_ms", null)
      field         = lookup(time_partitioning.value, "field", null)
      type          = lookup(time_partitioning.value, "type", null)
    }
  }
  dynamic "view" {
    for_each = var.view
    content {
      query          = lookup(view.value, "query", var.view_query)
      use_legacy_sql = lookup(view.value, "use_legacy_sql", null)
    }
  }
}

# --------------------------------------------------------------------
# BIGQUERY - DATA TRANSFER
# --------------------------------------------------------------------
resource "google_bigquery_data_transfer_config" "transfer" {
  count                     = var.data_transfer_create ? 1 : 0
  project                   = var.gcp_project
  location                  = var.gcp_region
  data_source_id            = var.data_source_id
  display_name              = var.display_name
  data_refresh_window_days  = var.data_refresh_window_days
  destination_dataset_id    = var.destination_dataset_id
  disabled                  = var.disabled
  notification_pubsub_topic = var.notification_pubsub_topic
  params = {
    allow_jagged_rows                 = lookup(var.params, "allow_jagged_rows", null)
    allow_quoted_newlines             = lookup(var.params, "allow_quoted_newlines", null)
    destination_table_name_template   = lookup(var.params, "destination_table_name_template", var.destination_table_id)
    data_path_template                = lookup(var.params, "data_path_template", null)
    decimal_target_types              = lookup(var.params, "decimal_target_types", null)
    delete_source_files               = lookup(var.params, "delete_source_files", null)
    encoding                          = lookup(var.params, "encoding", null)
    field_delimiter                   = lookup(var.params, "field_delimiter", null)
    file_format                       = lookup(var.params, "file_format", null)
    ignore_unknown_values             = lookup(var.params, "ignore_unknown_values", null)
    max_bad_records                   = lookup(var.params, "max_bad_records", null)
    parquet_enable_list_inference     = lookup(var.params, "parquet_enable_list_inference", null)
    parquet_enum_as_string            = lookup(var.params, "parquet_enum_as_string", null)
    preserve_ascii_control_characters = lookup(var.params, "preserve_ascii_control_characters", null)
    query                             = lookup(var.params, "query", var.query)
    quote                             = lookup(var.params, "quote", null)
    reference_file_schema_uri         = lookup(var.params, "reference_file_schema_uri", null)
    skip_leading_rows                 = lookup(var.params, "skip_leading_rows", null)
    source_project_id                 = lookup(var.params, "source_project_id", null)
    source_dataset_id                 = lookup(var.params, "source_dataset_id", null)
    overwrite_destination_table       = lookup(var.params, "overwrite_destination_table", null)
    use_avro_logical_types            = lookup(var.params, "use_avro_logical_types", null)
    write_disposition                 = lookup(var.params, "write_disposition", null)
  }
  schedule             = var.schedule
  service_account_name = var.service_account_name
  depends_on           = [google_bigquery_table.table]

  dynamic "email_preferences" {
    for_each = var.email_preferences
    content {
      enable_failure_email = lookup(email_preferences.value, "enable_failure_email", null)
    }
  }
  dynamic "schedule_options" {
    for_each = var.schedule_options
    content {
      disable_auto_scheduling = lookup(schedule_options.value, "disable_auto_scheduling", null)
      start_time              = lookup(schedule_options.value, "start_time", null)
      end_time                = lookup(schedule_options.value, "end_time", null)
    }
  }
  dynamic "sensitive_params" {
    for_each = var.sensitive_params
    content {
      secret_access_key = lookup(sensitive_params.value, "secret_access_key", null)
    }
  }
}

# --------------------------------------------------------------------
# BIGQUERY - ROUTINE
# --------------------------------------------------------------------
resource "google_bigquery_routine" "routines" {
  count           = var.routine_create ? 1 : 0
  dataset_id      = var.dataset_id
  routine_id      = var.routine_id
  routine_type    = var.routine_type
  language        = var.language
  definition_body = var.definition_body
  dynamic "arguments" {
    for_each = var.arguments_config
    content {
      name      = lookup(arguments.value, "name", null)
      data_type = jsonencode(arguments.value.data_type)
    }
  }
}
