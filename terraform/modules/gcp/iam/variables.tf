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
# IAM - SERVICE ACCOUNT CREATE
# --------------------------------------------------------------------
variable "sa_create" {
  type        = bool
  description = "Service account create"
  default     = false
}
variable "service_account_id" {
  type        = string
  description = "Service account id"
  default     = null
}
variable "create_ignore_already_exists" {
  type        = bool
  description = "Service account create ignore already exists"
  default     = null
}
variable "display_name" {
  type        = string
  description = "Service account display name"
  default     = null
}
variable "sa_description" {
  type        = string
  description = "Service account description"
  default     = null
}
variable "disabled" {
  type        = bool
  description = "Service account disabled"
  default     = null
}

# --------------------------------------------------------------------
# IAM - PROJECT/SERVICE ACCOUNT
# --------------------------------------------------------------------
variable "iam_type" {
  type        = string
  description = "Iam type"
  default     = null
}
variable "iam_role" {
  type        = string
  description = "Iam role"
  default     = null
}
variable "iam_member" {
  type        = string
  description = "Iam member"
  default     = null
}
variable "iam_members" {
  type        = list(string)
  description = "Iam members"
  default     = []
}
variable "service" {
  type        = string
  description = "Iam service"
  default     = null
}
variable "iam_condition" {
  description = "Iam condition"
  default     = []
}
variable "audit_log_config" {
  description = "Iam audit log config"
  default     = null
}
