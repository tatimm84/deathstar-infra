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

# --------------------------------------------------------------------
# APIS & SERVICES
# --------------------------------------------------------------------
variable "service" {
  type        = string
  description = "Apis & services service to enable"
}
variable "disable_dependent_services" {
  type        = bool
  description = "Apis & services disable dependent services"
  default     = null
}
variable "disable_on_destroy" {
  type        = bool
  description = "Apis & services disable on destroy"
  default     = null
}
