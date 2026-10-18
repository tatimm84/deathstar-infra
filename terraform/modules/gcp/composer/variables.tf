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
# COMPOSER
# --------------------------------------------------------------------
variable "composer_version" {
  type        = number
  description = "Composer version"
  default     = null
}
variable "name" {
  type        = string
  description = "Composer name"
  default     = null
}
variable "labels" {
  type        = map(string)
  description = "Composer labels"
  default     = null
}
variable "config" {
  description = "Composer config"
  default     = null
}
variable "storage_config" {
  description = "Composer storage config"
  default     = null
}
