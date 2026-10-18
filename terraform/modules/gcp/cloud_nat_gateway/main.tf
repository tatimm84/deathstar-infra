# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# CLOUD NAT GATEWAY - NETWORK CONNECTIVITY - CLOUD ROUTER
# --------------------------------------------------------------------
resource "google_compute_router" "router" {
  project                       = var.gcp_project
  region                        = var.gcp_region
  name                          = var.router
  network                       = var.network
  description                   = var.description
  encrypted_interconnect_router = var.encrypted_interconnect_router

  dynamic "bgp" {
    for_each = var.bgp
    content {
      asn                = lookup(bgp.value, "asn", null)
      advertise_mode     = lookup(bgp.value, "advertise_mode", null)
      advertised_groups  = lookup(bgp.value, "advertised_groups", null)
      keepalive_interval = lookup(bgp.value, "keepalive_interval", null)
      dynamic "advertised_ip_ranges" {
        for_each = lookup(bgp.value, "advertised_ip_ranges", {}) != {} ? [lookup(bgp.value, "advertised_ip_ranges")] : []
        content {
          range       = lookup(advertised_ip_ranges.value, "range", null)
          description = lookup(advertised_ip_ranges.value, "description", null)
        }
      }
    }
  }
}

# --------------------------------------------------------------------
# CLOUD NAT GATEWAY - NETWORK SERVICES - CLOUD NAT
# --------------------------------------------------------------------
resource "google_compute_router_nat" "nat" {
  project                             = var.gcp_project
  region                              = var.gcp_region
  name                                = var.nat
  router                              = var.router
  source_subnetwork_ip_ranges_to_nat  = var.source_subnetwork_ip_ranges_to_nat
  drain_nat_ips                       = var.drain_nat_ips
  enable_dynamic_port_allocation      = var.enable_dynamic_port_allocation
  enable_endpoint_independent_mapping = var.enable_endpoint_independent_mapping
  icmp_idle_timeout_sec               = var.icmp_idle_timeout_sec
  max_ports_per_vm                    = var.max_ports_per_vm
  min_ports_per_vm                    = var.min_ports_per_vm
  nat_ip_allocate_option              = var.nat_ip_allocate_option
  nat_ips                             = var.nat_ips
  tcp_established_idle_timeout_sec    = var.tcp_established_idle_timeout_sec
  tcp_transitory_idle_timeout_sec     = var.tcp_transitory_idle_timeout_sec
  udp_idle_timeout_sec                = var.udp_idle_timeout_sec
  depends_on                          = [google_compute_router.router]

  dynamic "log_config" {
    for_each = var.log_config
    content {
      enable = lookup(log_config.value, "enable", null)
      filter = lookup(log_config.value, "filter", null)
    }
  }
  dynamic "rules" {
    for_each = var.rules
    content {
      rule_number = lookup(rules.value, "rule_number", null)
      description = lookup(rules.value, "description", null)
      match       = lookup(rules.value, "match", null)
      dynamic "action" {
        for_each = lookup(rules.value, "action", {}) != {} ? [lookup(rules.value, "action")] : []
        content {
          source_nat_active_ips = lookup(action.value, "source_nat_active_ips", null)
          source_nat_drain_ips  = lookup(action.value, "source_nat_drain_ips", null)
          # source_nat_active_ranges = lookup(action.value, "source_nat_active_ranges")
          # source_nar_drain_ranges  = lookup(action.value, "source_nar_drain_ranges")
        }
      }
    }
  }
  dynamic "subnetwork" {
    for_each = var.subnetwork
    content {
      name                     = lookup(subnetwork.value, "name", null)
      source_ip_ranges_to_nat  = lookup(subnetwork.value, "source_ip_ranges_to_nat", null)
      secondary_ip_range_names = lookup(subnetwork.value, "secondary_ip_range_names", null)
    }
  }
}
