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
# SQL Database
# --------------------------------------------------------------------

## Instance variables
variable "sql_instance_create" {
  type        = bool
  description = "SQL Instance create"
  default     = true
}

variable "sql_instance_name" {
  type        = string
  description = "SQL Instance Name"
  default     = null
}

variable "database_version" {
  type        = string
  description = "Database Version"
  default     = null
}

variable "deletion_protection" {
  type        = bool
  description = "Deletion Protection"
  default     = false
}

variable "sql_instance_settings" {
  type        = any
  description = "SQL Instance Settings"
  default     = null
}

## Database variables
variable "sql_db_name" {
  type        = string
  description = "Database Name"
  default     = null
}

## Certificate variables
variable "sql_certs_name" {
  type        = string
  description = "SQL Certificate SSL Name"
  default     = null
}

## User variables
variable "sql_user_name" {
  type        = string
  description = "SQL User Name"
  default     = null
}

variable "sql_user_pw" {
  type        = string
  description = "SQL User Password"
  default     = null
}

# Secret variables
variable "sql_secret_client_key" {
  type        = any
  description = "Secret manager Client Key"
  default     = null
}

variable "sql_secret_client_pem" {
  type        = any
  description = "Secret manager Client PEM"
  default     = null
}

variable "sql_secret_server_ca_cert" {
  type        = any
  description = "Secret manager CA Certificate"
  default     = null
}
