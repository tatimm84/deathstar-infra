# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# OUTPUTS
# --------------------------------------------------------------------
output "sql_database_instance_id" {
  description = "SQL database instance id"
  value       = length(google_sql_database_instance.sql_database_instance) > 0 ? google_sql_database_instance.sql_database_instance[0].id : null
}
