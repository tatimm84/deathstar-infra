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

# --------------------------------------------------------------------
# FIRESTORE - DATABASE
# --------------------------------------------------------------------
variable "database_create" {
  type        = bool
  description = "Firestore database create"
  default     = true
}
variable "database" {
  type        = string
  description = "Firestore database name"
}
variable "type" {
  type        = string
  description = "Firestore database type"
  default     = null
}
variable "concurrency_mode" {
  type        = string
  description = "Firestore database concurrency mode"
  default     = null
}
variable "app_engine_integration_mode" {
  type        = string
  description = "Firestore database app engine integration mode"
  default     = null
}
variable "point_in_time_recovery_enablement" {
  type        = string
  description = "Firestore database point in time recovery enablement"
  default     = null
}
variable "delete_protection_state" {
  type        = string
  description = "Firestore database delete protection state"
  default     = null
}
variable "deletion_policy" {
  type        = string
  description = "Firestore database deletion policy"
  default     = null
}

# --------------------------------------------------------------------
# FIRESTORE - INDEX
# --------------------------------------------------------------------
variable "collection" {
  type        = string
  description = "Firestore collection"
  default     = null
}
variable "api_scope" {
  type        = string
  description = "Firestore index api scope"
  default     = null
}
variable "query_scope" {
  type        = string
  description = "Firestore index query scope"
  default     = null
}
variable "index_fields" {
  description = "Firestore index fields"
  default     = null
}

# --------------------------------------------------------------------
# FIRESTORE - DOCUMENT
# --------------------------------------------------------------------
variable "document_id" {
  type        = string
  description = "Firestore document id"
  default     = null
}
variable "document_fields" {
  type        = string
  description = "Firestore document fields"
  default     = null
}
