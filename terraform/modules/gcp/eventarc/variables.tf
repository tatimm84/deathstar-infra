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

# --------------------------------------------------------------------
# EVENTARC - TRIGGER
# --------------------------------------------------------------------
variable "name" {
  type        = string
  description = "Eventarc trigger name"
}
variable "channel" {
  type        = string
  description = "Eventarc trigger channel"
  default     = null
}
variable "event_data_content_type" {
  type        = string
  description = "Eventarc trigger event data content type"
  default     = null
}
variable "labels" {
  type        = map(string)
  description = "Eventarc trigger labels"
  default     = null
}
variable "service_account" {
  type        = string
  description = "Eventarc trigger service account"
  default     = null
}
variable "destination" {
  description = "Eventarc trigger destination"
  default     = null
}
variable "matching_criteria" {
  description = "Eventarc trigger matching criteria"
  default     = null
}
variable "transport" {
  description = "Eventarc trigger transport"
  default     = null
}
