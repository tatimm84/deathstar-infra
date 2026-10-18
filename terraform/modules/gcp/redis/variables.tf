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
# REDIS - INSTANCE
# --------------------------------------------------------------------
variable "name" {
  type        = string
  description = "Redis instance name"
}
variable "memory_size_gb" {
  type        = number
  description = "Redis instance memory size gb"
}
variable "alternative_location_id" {
  type        = string
  description = "Redis instance alternative location id"
  default     = null
}
variable "auth_enabled" {
  type        = bool
  description = "Redis instance auth enabled"
  default     = null
}
variable "authorized_network" {
  type        = string
  description = "Redis instance authorized network"
  default     = null
}
variable "connect_mode" {
  type        = string
  description = "Redis instance connect mode"
  default     = null
}
variable "customer_managed_key" {
  type        = string
  description = "Redis instance customer managed key"
  default     = null
}
variable "display_name" {
  type        = string
  description = "Redis instance display name"
  default     = null
}
variable "labels" {
  type        = map(string)
  description = "Redis instance labels"
  default     = null
}
variable "location_id" {
  type        = string
  description = "Redis instance location id"
  default     = null
}
variable "read_replicas_mode" {
  type        = string
  description = "Redis instance read replicas mode"
  default     = null
}
variable "redis_configs" {
  type        = map(string)
  description = "Redis instance configs"
  default     = null
}
variable "redis_version" {
  type        = string
  description = "Redis instance version"
  default     = null
}
variable "replica_count" {
  type        = number
  description = "Redis instance replica count"
  default     = null
}
variable "reserved_ip_range" {
  type        = string
  description = "Redis instance reserved ip range"
  default     = null
}
variable "secondary_ip_range" {
  type        = string
  description = "Redis instance secondary ip range"
  default     = null
}
variable "tier" {
  type        = string
  description = "Redis instance tier"
  default     = null
}
variable "transit_encryption_mode" {
  type        = string
  description = "Redis instance transit encryption mode"
  default     = null
}
variable "maintenance_policy" {
  description = "Redis instance maintenance policy"
  default     = null
}
variable "persistence_config" {
  description = "Redis instance persistence config"
  default     = null
}
