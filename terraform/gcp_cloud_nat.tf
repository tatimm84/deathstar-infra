# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# CLOUD NAT GATEWAY
# --------------------------------------------------------------------
locals {
  nat_gw = module.json_nat_reader.parsed_data
}

module "json_nat_reader" {
  source = "./modules/utils/reader"

  source_path = "${var.SRC_INFRA_PATH}/gcp/auto/cloud_nat_gateway/"
  enviroment  = var.ENVIRONMENT
  files_regex = "**"
  template_vars = {
    "__project_number__" = var.PROJECT_NUMBER,
    "__project_name__"   = var.GCP_PROJECT,
    "__region__"         = var.GCP_REGION,
    "__env__"            = var.ENVIRONMENT,
    "__uid_now__"        = var.UID_NOW
  }
}

module "gcp_cloud_nat_gateway" {
  for_each                            = { for entry in local.nat_gw : "${entry.source}" => entry }
  source                              = "./modules/gcp/cloud_nat_gateway"
  gcp_project                         = var.GCP_PROJECT
  gcp_region                          = lookup(each.value.content, "location", "") != "" ? lookup(each.value.content, "location") : var.GCP_REGION
  router                              = lookup(each.value.content, "router", "") != "" ? lookup(each.value.content, "router") : null
  network                             = lookup(each.value.content, "network", "") != "" ? lookup(each.value.content, "network") : null
  description                         = lookup(each.value.content, "description", "") != "" ? lookup(each.value.content, "description") : null
  encrypted_interconnect_router       = lookup(each.value.content, "encrypted_interconnect_router", "") != "" ? lookup(each.value.content, "encrypted_interconnect_router") : null
  bgp                                 = lookup(each.value.content, "bgp", {}) != {} ? [lookup(each.value.content, "bgp")] : []
  nat                                 = lookup(each.value.content, "nat", "") != "" ? lookup(each.value.content, "nat") : null
  source_subnetwork_ip_ranges_to_nat  = lookup(each.value.content, "source_subnetwork_ip_ranges_to_nat", "") != "" ? lookup(each.value.content, "source_subnetwork_ip_ranges_to_nat") : null
  drain_nat_ips                       = lookup(each.value.content, "drain_nat_ips", "") != "" ? lookup(each.value.content, "drain_nat_ips") : null
  enable_dynamic_port_allocation      = lookup(each.value.content, "enable_dynamic_port_allocation", "") != "" ? lookup(each.value.content, "enable_dynamic_port_allocation") : null
  enable_endpoint_independent_mapping = lookup(each.value.content, "enable_endpoint_independent_mapping", "") != "" ? lookup(each.value.content, "enable_endpoint_independent_mapping") : null
  icmp_idle_timeout_sec               = lookup(each.value.content, "icmp_idle_timeout_sec", "") != "" ? lookup(each.value.content, "icmp_idle_timeout_sec") : null
  max_ports_per_vm                    = lookup(each.value.content, "max_ports_per_vm", "") != "" ? lookup(each.value.content, "max_ports_per_vm") : null
  min_ports_per_vm                    = lookup(each.value.content, "min_ports_per_vm", "") != "" ? lookup(each.value.content, "min_ports_per_vm") : null
  nat_ip_allocate_option              = lookup(each.value.content, "nat_ip_allocate_option", "") != "" ? lookup(each.value.content, "nat_ip_allocate_option") : null
  nat_ips                             = lookup(each.value.content, "nat_ips", "") != "" ? lookup(each.value.content, "nat_ips") : null
  tcp_established_idle_timeout_sec    = lookup(each.value.content, "tcp_established_idle_timeout_sec", "") != "" ? lookup(each.value.content, "tcp_established_idle_timeout_sec") : null
  tcp_transitory_idle_timeout_sec     = lookup(each.value.content, "tcp_transitory_idle_timeout_sec", "") != "" ? lookup(each.value.content, "tcp_transitory_idle_timeout_sec") : null
  udp_idle_timeout_sec                = lookup(each.value.content, "udp_idle_timeout_sec", "") != "" ? lookup(each.value.content, "udp_idle_timeout_sec") : null
  log_config                          = lookup(each.value.content, "log_config", {}) != {} ? [lookup(each.value.content, "log_config")] : []
  rules                               = lookup(each.value.content, "rules", {}) != {} ? [lookup(each.value.content, "rules")] : []
  subnetwork                          = lookup(each.value.content, "subnetwork", {}) != {} ? [lookup(each.value.content, "subnetwork")] : []
  depends_on                          = [module.gcp_apis_services, module.gcp_vpc_network]
}
