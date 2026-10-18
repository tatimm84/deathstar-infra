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
# VPC NETWORK - IP ADDRESSES
# --------------------------------------------------------------------
variable "ip_type" {
  type        = string
  description = "Ip type"
  default     = null
}
variable "ip_name" {
  type        = string
  description = "Ip name"
  default     = null
}
variable "address" {
  type        = string
  description = "Ip address"
  default     = null
}
variable "address_type" {
  type        = string
  description = "Ip address type"
  default     = null
}
variable "ip_description" {
  type        = string
  description = "Ip description"
  default     = null
}
variable "ip_version" {
  type        = string
  description = "Ip version"
  default     = null
}
variable "ipv6_endpoint_type" {
  type        = string
  description = "Ip ipv6 endpoint type"
  default     = null
}
variable "labels" {
  type        = map(string)
  description = "Ip labels"
  default     = null
}
variable "network_tier" {
  type        = string
  description = "Ip network tier"
  default     = null
}
variable "prefix_length" {
  type        = number
  description = "Ip prefix length"
  default     = null
}
variable "ip_purpose" {
  type        = string
  description = "Ip purpose"
  default     = null
}

# --------------------------------------------------------------------
# VPC NETWORK - NETWORKS
# --------------------------------------------------------------------
variable "network_create" {
  type        = bool
  description = "Network create"
  default     = true
}
variable "network" {
  type        = string
  description = "Network name"
  default     = null
}
variable "auto_create_subnetworks" {
  type        = bool
  description = "Network auto create subnetworks"
  default     = null
}
variable "delete_default_routes_on_create" {
  type        = bool
  description = "Network delete default routes on create"
  default     = null
}
variable "network_description" {
  type        = string
  description = "Network description"
  default     = null
}
variable "enable_ula_internal_ipv6" {
  type        = bool
  description = "Network enable ula internal ipv6"
  default     = null
}
variable "internal_ipv6_range" {
  type        = string
  description = "Network internal ipv6 range"
  default     = null
}
variable "mtu" {
  type        = number
  description = "Network mtu"
  default     = null
}
variable "network_firewall_policy_enforcement_order" {
  type        = string
  description = "Network network firewall policy enforcement order"
  default     = null
}
variable "routing_mode" {
  type        = string
  description = "Network routing mode"
  default     = null
}

# --------------------------------------------------------------------
# VPC NETWORK - SUBNETWORKS
# --------------------------------------------------------------------
variable "subnetwork_create" {
  type        = bool
  description = "Subnetwork create"
  default     = true
}
variable "subnetwork" {
  type        = string
  description = "Subnetwork name"
  default     = null
}
variable "ip_cidr_range" {
  type        = string
  description = "Subnetwork ip cidr range"
  default     = null
}
variable "subnetwork_description" {
  type        = string
  description = "Subnetwork description"
  default     = null
}
variable "external_ipv6_prefix" {
  type        = string
  description = "Subnetwork external ipv6 prefix"
  default     = null
}
variable "subnetwork_purpose" {
  type        = string
  description = "Subnetwork purpose"
  default     = null
}
variable "role" {
  type        = string
  description = "Subnetwork role"
  default     = null
}
variable "private_ip_google_access" {
  type        = bool
  description = "Subnetwork private ip google access"
  default     = null
}
variable "private_ipv6_google_access" {
  type        = string
  description = "Subnetwork private ipv6 google access"
  default     = null
}
variable "stack_type" {
  type        = string
  description = "Subnetwork stack type"
  default     = null
}
variable "ipv6_access_type" {
  type        = string
  description = "Subnetwork ipv6 access type"
  default     = null
}
variable "secondary_ip_range" {
  description = "Subnetwork secondary ip range"
  default     = []
}
variable "subnetwork_log_config" {
  description = "Subnetwork log config"
  default     = []
}

# --------------------------------------------------------------------
# NETWORK SECURITY - FIREWALL POLICY
# --------------------------------------------------------------------
variable "firewall_name" {
  type        = string
  description = "Firewall name"
  default     = null
}
variable "firewall_description" {
  type        = string
  description = "Firewall description"
  default     = null
}
variable "destination_ranges" {
  type        = set(string)
  description = "Firewall destination ranges"
  default     = null
}
variable "direction" {
  type        = string
  description = "Firewall direction"
  default     = null
}
variable "disabled" {
  type        = bool
  description = "Firewall disabled"
  default     = null
}
variable "priority" {
  type        = number
  description = "Firewall priority"
  default     = null
}
variable "source_ranges" {
  type        = set(string)
  description = "Firewall source ranges"
  default     = null
}
variable "source_service_accounts" {
  type        = set(string)
  description = "Firewall source service accounts"
  default     = null
}
variable "source_tags" {
  type        = set(string)
  description = "Firewall source tags"
  default     = null
}
variable "target_service_accounts" {
  type        = set(string)
  description = "Firewall target service accounts"
  default     = null
}
variable "target_tags" {
  type        = set(string)
  description = "Firewall target tags"
  default     = null
}
variable "allow" {
  description = "Firewall allow"
  default     = []
}
variable "deny" {
  description = "Firewall deny"
  default     = []
}
variable "firewall_log_config" {
  # type = object({
  #   enable   = bool
  #   log_type = string
  # })
  # default = {
  #   enable   = false
  #   log_type = "NONE"
  # }
  description = "Firewall log config"
  default     = []
}

# --------------------------------------------------------------------
# VPC NETWORK - ACCESS CONECTOR
# --------------------------------------------------------------------
variable "access_connector" {
  type        = string
  description = "Access connector name"
  default     = null
}

variable "access_connector_vm_type" {
  type        = string
  description = "Access connector Virtual Machine Type"
  default     = "e2-micro"
}

variable "access_connector_subnetwork_name" {
  type        = string
  description = "Access connector - Subnetwork Name"
  default     = null
}

variable "access_connector_subnetwork_project" {
  type        = string
  description = "Access connector - Subnetwork Project"
  default     = null
}

variable "access_connector_vm_min_instances" {
  type        = number
  description = "Access connector VM Min Instances"
  default     = 2
}

variable "access_connector_vm_max_instances" {
  type        = number
  description = "Access connector VM Max Instances"
  default     = 3
}
variable "access_connector_vm_min_throughput" {
  type        = number
  description = "Access connector VM Min Throughput"
  default     = null
}
variable "access_connector_vm_max_throughput" {
  type        = number
  description = "Access connector VM Max Throughput"
  default     = null
}

# --------------------------------------------------------------------
# VPC NETWORK - SERVICE NETWORKING CONNECTION
# --------------------------------------------------------------------
variable "service_networking_connection" {
  type        = string
  description = "Service Networking Connection"
  default     = null
}
