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
  default     = "southamerica-east1"
}
variable "RUNNING_SERVICE_ACCOUNT" {
  type        = string
  description = "Service Account used to run the resources"
  default     = null
}

# --------------------------------------------------------------------
# CLOUD SCHEDULER - JOB
# --------------------------------------------------------------------
variable "name" {
  type        = string
  description = "Cloud scheduler name"
}
variable "attempt_deadline" {
  type        = string
  description = "Cloud scheduler attempt deadline"
  default     = null
}
variable "description" {
  type        = string
  description = "Cloud scheduler description"
  default     = null
}
variable "paused" {
  type        = bool
  description = "Cloud scheduler paused"
  default     = false
}
variable "schedule" {
  type        = string
  description = "Cloud scheduler schedule"
  default     = null
}
variable "time_zone" {
  type        = string
  description = "Cloud scheduler time zone"
  default     = null
}
variable "retry_config" {
  description = "Cloud scheduler retry config"
  default     = []
}
variable "pubsub_target" {
  description = "Cloud scheduler pubsub target"
  default     = []
}
variable "app_engine_http_target" {
  description = "Cloud scheduler app engine http target"
  default     = []
}
variable "http_target" {
  description = "Cloud scheduler http target"
  default     = []
}
