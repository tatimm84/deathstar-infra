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
# WORKFLOWS
# --------------------------------------------------------------------
variable "name" {
  type        = string
  description = "Workflow name"
}
variable "name_prefix" {
  type        = string
  description = "Workflow name prefix"
}
variable "call_log_level" {
  type        = string
  description = "Workflow call log level"
  default     = null
}
variable "crypto_key_name" {
  type        = string
  description = "Workflow crypto key name"
  default     = null
}
variable "description" {
  type        = string
  description = "Workflow description"
  default     = null
}
variable "labels" {
  type        = map(string)
  description = "Workflow labels"
  default     = null
}
variable "service_account" {
  type        = string
  description = "Workflow service account"
  default     = null
}
variable "source_contents" {
  type        = string
  description = "Workflow source contents"
  default     = null
}
variable "user_env_vars" {
  type        = map(string)
  description = "Workflow user env vars"
  default     = null
}
