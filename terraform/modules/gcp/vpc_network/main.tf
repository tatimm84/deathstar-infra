# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# VPC NETWORK - IP ADDRESSES
# --------------------------------------------------------------------
resource "google_compute_global_address" "global_ip" {
  count         = var.ip_type == "global" ? 1 : 0
  project       = var.gcp_project
  name          = var.ip_name
  address       = var.address
  address_type  = var.address_type
  description   = var.ip_description
  ip_version    = var.ip_version
  network       = var.address_type == "INTERNAL" ? var.network : null
  prefix_length = var.prefix_length
  purpose       = var.ip_purpose
}
resource "google_compute_address" "regional_ip" {
  count              = var.ip_type == "regional" ? 1 : 0
  project            = var.gcp_project
  region             = var.gcp_region
  name               = var.ip_name
  address            = var.address
  address_type       = var.address_type
  description        = var.ip_description
  ip_version         = var.ip_version
  ipv6_endpoint_type = var.ipv6_endpoint_type
  labels             = var.labels
  network            = var.network
  network_tier       = var.network_tier
  prefix_length      = var.prefix_length
  purpose            = var.ip_purpose
  subnetwork         = var.subnetwork
}

# --------------------------------------------------------------------
# VPC NETWORK - NETWORKS
# --------------------------------------------------------------------
resource "google_compute_network" "network" {
  count                                     = var.network_create ? 1 : 0
  project                                   = var.gcp_project
  name                                      = var.network
  auto_create_subnetworks                   = var.auto_create_subnetworks
  delete_default_routes_on_create           = var.delete_default_routes_on_create
  description                               = var.network_description
  enable_ula_internal_ipv6                  = var.enable_ula_internal_ipv6
  internal_ipv6_range                       = var.internal_ipv6_range
  mtu                                       = var.mtu
  network_firewall_policy_enforcement_order = var.network_firewall_policy_enforcement_order
  routing_mode                              = var.routing_mode
}

# --------------------------------------------------------------------
# VPC NETWORK - SUBNETWORKS
# --------------------------------------------------------------------
resource "google_compute_subnetwork" "subnetwork" {
  count                      = var.subnetwork_create ? 1 : 0
  project                    = var.gcp_project
  region                     = var.gcp_region
  name                       = var.subnetwork
  ip_cidr_range              = var.ip_cidr_range
  network                    = var.network
  description                = var.subnetwork_description
  external_ipv6_prefix       = var.external_ipv6_prefix
  purpose                    = var.subnetwork_purpose
  role                       = var.role
  private_ip_google_access   = var.private_ip_google_access
  private_ipv6_google_access = var.private_ipv6_google_access
  stack_type                 = var.stack_type
  ipv6_access_type           = var.ipv6_access_type
  depends_on                 = [google_compute_network.network]

  dynamic "secondary_ip_range" {
    for_each = var.secondary_ip_range
    content {
      range_name    = lookup(secondary_ip_range.value, "range_name", null)
      ip_cidr_range = lookup(secondary_ip_range.value, "ip_cidr_range", null)
    }
  }

  dynamic "log_config" {
    for_each = var.subnetwork_log_config
    content {
      aggregation_interval = lookup(log_config.value, "aggregation_interval", null)
      flow_sampling        = lookup(log_config.value, "flow_sampling", null)
      metadata             = lookup(log_config.value, "metadata", null)
      metadata_fields      = lookup(log_config.value, "metadata_fields", null)
      filter_expr          = lookup(log_config.value, "filter_expr", null)
    }
  }
}

# --------------------------------------------------------------------
# VPC NETWORK - NETWORK SECURITY - FIREWALL POLICY
# --------------------------------------------------------------------
resource "google_compute_firewall" "firewall" {
  count                   = var.firewall_name != null ? 1 : 0
  project                 = var.gcp_project
  name                    = var.firewall_name
  network                 = var.network
  description             = var.firewall_description
  destination_ranges      = var.destination_ranges
  direction               = var.direction
  disabled                = var.disabled
  priority                = var.priority
  source_ranges           = var.source_ranges
  source_service_accounts = var.source_service_accounts
  source_tags             = var.source_tags
  target_service_accounts = var.target_service_accounts
  target_tags             = var.target_tags
  depends_on              = [google_compute_network.network]

  dynamic "allow" {
    for_each = var.allow
    content {
      protocol = lookup(allow.value, "protocol", null)
      ports    = lookup(allow.value, "ports", null)
    }
  }
  dynamic "deny" {
    for_each = var.deny
    content {
      protocol = lookup(deny.value, "protocol", null)
      ports    = lookup(deny.value, "ports", null)
    }
  }
  dynamic "log_config" {
    for_each = var.firewall_log_config
    content {
      metadata = lookup(log_config.value, "metadata", null)
    }
  }
}

# --------------------------------------------------------------------
# VPC NETWORK - ACCESS CONECTOR
# --------------------------------------------------------------------

resource "google_vpc_access_connector" "connector" {
  count          = var.access_connector != null ? 1 : 0
  project        = var.gcp_project
  region         = var.gcp_region
  name           = var.access_connector
  network        = var.access_connector_subnetwork_name == null && var.subnetwork == null ? var.network : null
  ip_cidr_range  = var.access_connector_subnetwork_name == null && var.subnetwork == null ? var.ip_cidr_range : null
  machine_type   = var.access_connector_vm_type
  min_instances  = var.access_connector_vm_min_instances
  max_instances  = var.access_connector_vm_max_instances
  min_throughput = var.access_connector_vm_min_throughput
  max_throughput = var.access_connector_vm_max_throughput

  subnet {
    name       = var.access_connector_subnetwork_name != null ? var.access_connector_subnetwork_name : var.subnetwork
    project_id = var.access_connector_subnetwork_project != null ? var.access_connector_subnetwork_project : var.gcp_project
  }
  depends_on = [google_compute_subnetwork.subnetwork]
}

# --------------------------------------------------------------------
# VPC NETWORK - SERVICE NETWORKING CONNECTION
# --------------------------------------------------------------------
resource "google_service_networking_connection" "service_networking_connection" {
  count                   = var.service_networking_connection != null ? 1 : 0
  network                 = var.network
  service                 = var.service_networking_connection
  reserved_peering_ranges = [var.ip_name]
}
