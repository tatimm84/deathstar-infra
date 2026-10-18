# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# FIRESTORE - DATABASE
# --------------------------------------------------------------------
resource "google_firestore_database" "database" {
  count                             = var.database_create ? 1 : 0
  project                           = var.gcp_project
  location_id                       = var.gcp_region
  name                              = var.database
  type                              = var.type
  concurrency_mode                  = var.concurrency_mode
  app_engine_integration_mode       = var.app_engine_integration_mode
  point_in_time_recovery_enablement = var.point_in_time_recovery_enablement
  delete_protection_state           = var.delete_protection_state
  deletion_policy                   = var.deletion_policy
}

# -------------------------------------------------------------
# FIRESTORE - INDEX
# -------------------------------------------------------------
resource "google_firestore_index" "database_index" {
  count       = var.index_fields != null ? 1 : 0
  project     = var.gcp_project
  database    = var.database
  collection  = var.collection
  api_scope   = var.api_scope
  query_scope = var.query_scope
  depends_on  = [google_firestore_database.database]

  dynamic "fields" {
    for_each = var.index_fields
    content {
      field_path   = lookup(fields.value, "field_path", null)
      order        = lookup(fields.value, "order", null)
      array_config = lookup(fields.value, "array_config", null)
      dynamic "vector_config" {
        for_each = lookup(fields.value, "vector_config", {}) != {} ? [lookup(fields.value, "vector_config")] : []
        content {
          dimension = lookup(vector_config.value, "dimension", null)
          flat {}
        }
      }
    }
  }
}

# --------------------------------------------------------------------
# FIRESTORE - DOCUMENT
# --------------------------------------------------------------------
resource "google_firestore_document" "document" {
  count       = var.document_fields != null ? 1 : 0
  project     = var.gcp_project
  database    = var.database
  collection  = var.collection
  document_id = var.document_id
  fields      = var.document_fields
  depends_on  = [google_firestore_database.database]
}
