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
# CLOUD NAT GATEWAY - NETWORK CONNECTIVITY - CLOUD ROUTER
# --------------------------------------------------------------------
variable "router" {
  type        = string
  description = "Cloud router name"
}
variable "network" {
  type        = string
  description = "Cloud router network"
}
variable "description" {
  type        = string
  description = "Cloud router description"
  default     = null
}
variable "encrypted_interconnect_router" {
  type        = string
  description = "Cloud router encrypted interconnect router"
  default     = null
}
variable "bgp" {
  description = "Cloud router bgp"
  default     = null
}

# --------------------------------------------------------------------
# CLOUD NAT GATEWAY - NETWORK SERVICES - CLOUD NAT
# --------------------------------------------------------------------
variable "nat" {
  type        = string
  description = "Cloud nat name"
}
variable "source_subnetwork_ip_ranges_to_nat" {
  type        = string
  description = "Cloud nat source subnetwork ip ranges to nat"
}
variable "drain_nat_ips" {
  type        = set(string)
  description = "Cloud nat ips drain"
  default     = null
}
variable "enable_dynamic_port_allocation" {
  type        = bool
  description = "Cloud nat enable dynamic port allocation"
  default     = null
}
variable "enable_endpoint_independent_mapping" {
  type        = bool
  description = "Cloud nat enable endpoint independent mapping"
  default     = null
}
variable "icmp_idle_timeout_sec" {
  type        = number
  description = "Cloud nat icmp idle timeout sec"
  default     = null
}
variable "max_ports_per_vm" {
  type        = number
  description = "Cloud nat max ports per vm"
  default     = null
}
variable "min_ports_per_vm" {
  type        = number
  description = "Cloud nat min ports per vm"
  default     = null
}
variable "nat_ip_allocate_option" {
  type        = string
  description = "Cloud nat ip allocate option"
  default     = null
}
variable "nat_ips" {
  type        = set(string)
  description = "Cloud nat ips"
  default     = null
}
variable "tcp_established_idle_timeout_sec" {
  type        = number
  description = "Cloud nat tcp established idle timeout sec"
  default     = null
}
variable "tcp_transitory_idle_timeout_sec" {
  type        = number
  description = "Cloud nat tcp transitory idle timeout sec"
  default     = null
}
variable "udp_idle_timeout_sec" {
  type        = number
  description = "Cloud nat udp idle timeout sec"
  default     = null
}
variable "log_config" {
  description = "Cloud nat log config"
  default     = null
}
variable "rules" {
  description = "Cloud nat rules"
  default     = null
}
variable "subnetwork" {
  description = "Cloud nat subnetwork"
  default     = null
}
