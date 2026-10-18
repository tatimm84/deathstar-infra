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
}

# --------------------------------------------------------------------
# CERTIFICATE MANAGER - SSL CERTIFICATE
# --------------------------------------------------------------------
variable "certificate" {
  type        = string
  description = "Certificate manager ssl certificate"
  default     = null
}
variable "private_key" {
  type        = string
  description = "Certificate manager ssl private_key"
  default     = null
}
variable "ssl_certificate" {
  type        = string
  description = "Certificate manager ssl certificate name"
  default     = null
}

variable "ssl_certificate_type" {
  type        = string
  description = "Certificate manager ssl certificate type"
  default     = "global"
}

variable "ssl_certificate_description" {
  type        = string
  description = "Certificate manager ssl certificate description"
  default     = null
}
variable "name_prefix" {
  type        = string
  description = "Certificate manager ssl certificate name prefix"
  default     = null
}

# --------------------------------------------------------------------
# NETWORK SERVICES - SSL POLICIES
# --------------------------------------------------------------------
variable "ssl_policy" {
  type        = string
  description = "Netowrk services ssl policy name"
  default     = null
}
variable "ssl_policy_type" {
  type        = string
  description = "Netowrk services ssl policy type"
  default     = "global"
}

variable "profile" {
  type        = string
  description = "Netowrk services ssl policy profile"
  default     = null
}
variable "min_tls_version" {
  type        = string
  description = "Netowrk services ssl policy min tls version"
  default     = null
}
variable "custom_features" {
  type        = set(string)
  description = "Netowrk services ssl policy custom features"
  default     = null
}

# --------------------------------------------------------------------
# NETWORK SECURITY - CLOUD ARMOR POLICIES
# --------------------------------------------------------------------
variable "armor" {
  type        = string
  description = "Netowrk security cloud armor policy name"
  default     = null
}
variable "armor_description" {
  type        = string
  description = "Netowrk security cloud armor description"
  default     = null
}
variable "type" {
  type        = string
  description = "Netowrk security cloud armor type"
  default     = null
}
variable "advanced_options_config" {
  description = "Netowrk security cloud armor advanced options config"
  default     = []
}
variable "adaptive_protection_config" {
  description = "Netowrk security cloud armor adaptive protection config"
  default     = []
}
variable "recaptcha_options_config" {
  description = "Netowrk security cloud armor recaptcha options config"
  default     = []
}
variable "rule" {
  description = "Netowrk security cloud armor rule"
  default     = []
}
