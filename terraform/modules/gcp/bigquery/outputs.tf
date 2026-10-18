# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# OUTPUTS
# --------------------------------------------------------------------
output "dataset_id" {
  description = "Bigquery dataset id"
  value       = length(google_bigquery_dataset.dataset) > 0 ? google_bigquery_dataset.dataset[0].id : null
}
output "dataset_self_link" {
  description = "Bigquery dataset self link"
  value       = length(google_bigquery_dataset.dataset) > 0 ? google_bigquery_dataset.dataset[0].self_link : null
}
output "table_id" {
  description = "Bigquery table id"
  value       = length(google_bigquery_table.table) > 0 ? google_bigquery_table.table[0].id : null
}
output "table_self_link" {
  description = "Bigquery table self link"
  value       = length(google_bigquery_table.table) > 0 ? google_bigquery_table.table[0].self_link : null
}
output "data_transfer_id" {
  description = "Bigquery data transfer id"
  value       = length(google_bigquery_data_transfer_config.transfer) > 0 ? google_bigquery_data_transfer_config.transfer[0].id : null
}
output "data_transfer_name" {
  description = "Bigquery data transfer name"
  value       = length(google_bigquery_data_transfer_config.transfer) > 0 ? google_bigquery_data_transfer_config.transfer[0].name : null
}
output "routine_id" {
  description = "Bigquery routine id"
  value       = length(google_bigquery_routine.routines) > 0 ? google_bigquery_routine.routines[0].id : null
}
