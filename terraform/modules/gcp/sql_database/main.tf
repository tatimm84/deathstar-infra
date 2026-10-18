# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# SQL Database Create Instance
# --------------------------------------------------------------------
resource "google_sql_database_instance" "sql_database_instance" {
  count               = var.sql_instance_create ? 1 : 0
  name                = var.sql_instance_name
  project             = var.gcp_project
  region              = var.gcp_region
  database_version    = var.database_version
  deletion_protection = var.deletion_protection

  dynamic "settings" {
    for_each = var.sql_instance_settings
    content {
      tier              = lookup(settings.value, "tier", null)
      availability_type = lookup(settings.value, "availability_type", null)
      disk_size         = lookup(settings.value, "disk_size", null)

      dynamic "backup_configuration" {
        for_each = lookup(settings.value, "backup_configuration", {}) != {} ? [lookup(settings.value, "backup_configuration")] : []
        content {
          enabled    = lookup(backup_configuration.value, "enabled", null)
          start_time = lookup(backup_configuration.value, "start_time", null)
        }
      }
      dynamic "ip_configuration" {
        for_each = lookup(settings.value, "ip_configuration", {}) != {} ? [lookup(settings.value, "ip_configuration")] : []
        content {
          ipv4_enabled    = lookup(ip_configuration.value, "ipv4_enabled", null)
          private_network = lookup(ip_configuration.value, "private_network", null)
          # require_ssl     = lookup(ip_configuration.value, "require_ssl", null)
          ssl_mode = lookup(ip_configuration.value, "ssl_mode", null)
        }
      }
    }
  }
}

# --------------------------------------------------------------------
# SQL Database Create Database
# --------------------------------------------------------------------
resource "google_sql_database" "database" {
  count    = var.sql_db_name != null ? 1 : 0
  name     = var.sql_db_name
  project  = var.gcp_project
  instance = var.sql_instance_name

  depends_on = [google_sql_database_instance.sql_database_instance]
}

resource "google_sql_ssl_cert" "sql_certs" {
  count       = var.sql_certs_name != null ? 1 : 0
  project     = var.gcp_project
  common_name = var.sql_certs_name
  instance    = var.sql_instance_name

  depends_on = [
    google_sql_database_instance.sql_database_instance,
    google_sql_database.database
  ]
}

# --------------------------------------------------------------------
# SQL Database Create User
# --------------------------------------------------------------------
resource "google_sql_user" "user" {
  count    = var.sql_user_name != null ? 1 : 0
  name     = var.sql_user_name
  project  = var.gcp_project
  instance = var.sql_instance_name
  password = var.sql_user_pw

  depends_on = [
    google_sql_database_instance.sql_database_instance,
    google_sql_database.database
  ]
}

# --------------------------------------------------------------------
# SQL Secret Manager
# --------------------------------------------------------------------

locals {
  sql_secret = distinct(flatten([
    for item in [
      ["client_key", var.sql_secret_client_key],
      ["client_pem", var.sql_secret_client_pem],
      ["server_ca_cert", var.sql_secret_server_ca_cert]
      ] : [{
        name    = lookup(item[1], "secret_name", "") != "" ? lookup(item[1], "secret_name") : null
        type    = item[0]
        content = item[1]
    }] if item[1] != null
  ]))

  sql_members = distinct(flatten([
    for item in local.sql_secret : [
      for member in lookup(item.content, "iam_members", []) : {
        type   = "${item.type}_${member}"
        name   = item.name
        member = member
        role   = lookup(item.content, "iam_member_role", null)
      }
    ]
  ]))
}

resource "google_secret_manager_secret" "secret-sql" {
  for_each  = { for entry in local.sql_secret : "${entry.type}" => entry }
  secret_id = each.value.name
  project   = var.gcp_project

  labels      = lookup(each.value.content, "labels", null)
  annotations = lookup(each.value.content, "annotations", null)

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "secret-version-sql" {
  for_each = { for entry in local.sql_secret : "${entry.type}" => entry }
  secret   = "projects/${var.gcp_project}/secrets/${each.value.name}"

  secret_data = (
    each.value.type == "client_key" ? google_sql_ssl_cert.sql_certs[0].private_key :
    (
      each.value.type == "client_pem" ? google_sql_ssl_cert.sql_certs[0].cert :
      (
        each.value.type == "server_ca_cert" ? google_sql_ssl_cert.sql_certs[0].server_ca_cert :
        lookup(each.value.content, "secret_data", null)
      )
    )
  )
  depends_on = [google_secret_manager_secret.secret-sql, google_sql_ssl_cert.sql_certs[0]]
}
resource "google_secret_manager_secret_iam_member" "member-sql" {
  for_each   = { for entry in local.sql_members : "${entry.type}" => entry }
  project    = var.gcp_project
  secret_id  = "projects/${var.gcp_project}/secrets/${each.value.name}"
  role       = each.value.role
  member     = each.value.member
  depends_on = [google_secret_manager_secret.secret-sql]
}
