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
# GCLOUD - CMD Instruction
# --------------------------------------------------------------------
variable "sha1_json" {
  type        = string
  description = "CMD - Hash SHA1"
  default     = null
}

variable "cmd_instruction" {
  type        = string
  description = "Command instruction"
  default     = true
}
