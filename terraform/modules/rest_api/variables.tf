# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# REST API
# --------------------------------------------------------------------
variable "method" {
  type        = string
  description = "Rest api method"
}
variable "url" {
  type        = string
  description = "Rest api url"
}
variable "token" {
  type        = string
  description = "Rest api token"
  default     = null
}
variable "data" {
  type        = string
  description = "Rest api data"
  default     = null
}
