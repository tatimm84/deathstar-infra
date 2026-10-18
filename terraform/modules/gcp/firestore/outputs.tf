# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# OUTPUTS
# --------------------------------------------------------------------
output "database_id" {
  description = "Firestore database id"
  value       = length(google_firestore_database.database) > 0 ? google_firestore_database.database[0].id : null
}
output "database_name" {
  description = "Firestore database name"
  value       = length(google_firestore_database.database) > 0 ? google_firestore_database.database[0].name : null
}
output "document_id" {
  description = "Firestore document id"
  value       = length(google_firestore_document.document) > 0 ? google_firestore_document.document[0].id : null
}
output "document_name" {
  description = "Firestore document name"
  value       = length(google_firestore_document.document) > 0 ? google_firestore_document.document[0].name : null
}
