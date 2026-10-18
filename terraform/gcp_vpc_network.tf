# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# VPC NETWORK
# --------------------------------------------------------------------
locals {
  network = module.json_network_reader.parsed_data
}

module "json_network_reader" {
  source = "./modules/utils/reader"

  source_path = "${var.SRC_INFRA_PATH}/gcp/auto/vpc_network/"
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

module "gcp_vpc_network" {
  for_each                                  = { for entry in local.network : "${entry.source}" => entry }
  source                                    = "./modules/gcp/vpc_network"
  gcp_project                               = var.GCP_PROJECT
  ip_type                                   = lookup(each.value.content, "ip_type", "") != "" ? lookup(each.value.content, "ip_type") : null
  ip_name                                   = lookup(each.value.content, "ip_name", "") != "" ? lookup(each.value.content, "ip_name") : null
  address                                   = lookup(each.value.content, "address", "") != "" ? lookup(each.value.content, "address") : null
  address_type                              = lookup(each.value.content, "address_type", "") != "" ? lookup(each.value.content, "address_type") : null
  ip_description                            = lookup(each.value.content, "ip_description", "") != "" ? lookup(each.value.content, "ip_description") : null
  ip_version                                = lookup(each.value.content, "ip_version", "") != "" ? lookup(each.value.content, "ip_version") : null
  ipv6_endpoint_type                        = lookup(each.value.content, "ipv6_endpoint_type", "") != "" ? lookup(each.value.content, "ipv6_endpoint_type") : null
  labels                                    = lookup(each.value.content, "labels", {}) != {} ? lookup(each.value.content, "labels") : null
  network                                   = lookup(each.value.content, "network", "") != "" ? lookup(each.value.content, "network") : null
  network_tier                              = lookup(each.value.content, "network_tier", "") != "" ? lookup(each.value.content, "network_tier") : null
  prefix_length                             = lookup(each.value.content, "prefix_length", "") != "" ? lookup(each.value.content, "prefix_length") : null
  ip_purpose                                = lookup(each.value.content, "ip_purpose", "") != "" ? lookup(each.value.content, "ip_purpose") : null
  subnetwork                                = lookup(each.value.content, "subnetwork", "") != "" ? lookup(each.value.content, "subnetwork") : null
  network_create                            = lookup(each.value.content, "network_create", "") != "" ? lookup(each.value.content, "network_create") : true
  auto_create_subnetworks                   = lookup(each.value.content, "auto_create_subnetworks", "") != "" ? lookup(each.value.content, "auto_create_subnetworks") : null
  delete_default_routes_on_create           = lookup(each.value.content, "delete_default_routes_on_create", "") != "" ? lookup(each.value.content, "delete_default_routes_on_create") : null
  network_description                       = lookup(each.value.content, "network_description", "") != "" ? lookup(each.value.content, "network_description") : null
  enable_ula_internal_ipv6                  = lookup(each.value.content, "enable_ula_internal_ipv6", "") != "" ? lookup(each.value.content, "enable_ula_internal_ipv6") : null
  internal_ipv6_range                       = lookup(each.value.content, "internal_ipv6_range", "") != "" ? lookup(each.value.content, "internal_ipv6_range") : null
  mtu                                       = lookup(each.value.content, "mtu", "") != "" ? lookup(each.value.content, "mtu") : null
  network_firewall_policy_enforcement_order = lookup(each.value.content, "network_firewall_policy_enforcement_order", "") != "" ? lookup(each.value.content, "network_firewall_policy_enforcement_order") : null
  routing_mode                              = lookup(each.value.content, "routing_mode", "") != "" ? lookup(each.value.content, "routing_mode") : null
  subnetwork_create                         = lookup(each.value.content, "subnetwork_create", "") != "" ? lookup(each.value.content, "subnetwork_create") : true
  ip_cidr_range                             = lookup(each.value.content, "ip_cidr_range", "") != "" ? lookup(each.value.content, "ip_cidr_range") : null
  gcp_region                                = lookup(each.value.content, "gcp_region", "") != "" ? lookup(each.value.content, "gcp_region") : null
  subnetwork_description                    = lookup(each.value.content, "subnetwork_description", "") != "" ? lookup(each.value.content, "subnetwork_description") : null
  external_ipv6_prefix                      = lookup(each.value.content, "external_ipv6_prefix", "") != "" ? lookup(each.value.content, "external_ipv6_prefix") : null
  subnetwork_purpose                        = lookup(each.value.content, "subnetwork_purpose", "") != "" ? lookup(each.value.content, "subnetwork_purpose") : null
  role                                      = lookup(each.value.content, "role", "") != "" ? lookup(each.value.content, "role") : null
  private_ip_google_access                  = lookup(each.value.content, "private_ip_google_access", "") != "" ? lookup(each.value.content, "private_ip_google_access") : null
  private_ipv6_google_access                = lookup(each.value.content, "private_ipv6_google_access", "") != "" ? lookup(each.value.content, "private_ipv6_google_access") : null
  stack_type                                = lookup(each.value.content, "stack_type", "") != "" ? lookup(each.value.content, "stack_type") : null
  ipv6_access_type                          = lookup(each.value.content, "ipv6_access_type", "") != "" ? lookup(each.value.content, "ipv6_access_type") : null
  secondary_ip_range                        = lookup(each.value.content, "secondary_ip_range", []) != [] ? [lookup(each.value.content, "secondary_ip_range")] : []
  subnetwork_log_config                     = lookup(each.value.content, "subnetwork_log_config", {}) != {} ? [lookup(each.value.content, "subnetwork_log_config")] : []
  firewall_name                             = lookup(each.value.content, "firewall_name", "") != "" ? lookup(each.value.content, "firewall_name") : null
  firewall_description                      = lookup(each.value.content, "firewall_description", "") != "" ? lookup(each.value.content, "firewall_description") : null
  destination_ranges                        = lookup(each.value.content, "destination_ranges", []) != [] ? lookup(each.value.content, "destination_ranges") : null
  direction                                 = lookup(each.value.content, "direction", "") != "" ? lookup(each.value.content, "direction") : null
  disabled                                  = lookup(each.value.content, "disabled", "") != "" ? lookup(each.value.content, "disabled") : null
  priority                                  = lookup(each.value.content, "priority", "") != "" ? lookup(each.value.content, "priority") : null
  source_ranges                             = lookup(each.value.content, "source_ranges", []) != [] ? lookup(each.value.content, "source_ranges") : null
  source_service_accounts                   = lookup(each.value.content, "source_service_accounts", []) != [] ? lookup(each.value.content, "source_service_accounts") : null
  source_tags                               = lookup(each.value.content, "source_tags", []) != [] ? lookup(each.value.content, "source_tags") : null
  target_service_accounts                   = lookup(each.value.content, "target_service_accounts", []) != [] ? lookup(each.value.content, "target_service_accounts") : null
  target_tags                               = lookup(each.value.content, "target_tags", []) != [] ? lookup(each.value.content, "target_tags") : null
  allow                                     = try(each.value.content["allow"], []) != [] ? each.value.content["allow"] : []
  deny                                      = try(each.value.content["deny"], []) != [] ? each.value.content["deny"] : []
  firewall_log_config                       = lookup(each.value.content, "firewall_log_config", {}) != {} ? [lookup(each.value.content, "firewall_log_config")] : []
  access_connector                          = lookup(each.value.content, "access_connector", "") != "" ? lookup(each.value.content, "access_connector") : null
  access_connector_subnetwork_name          = lookup(each.value.content, "access_connector_subnetwork_name", "") != "" ? lookup(each.value.content, "access_connector_subnetwork_name") : null
  access_connector_subnetwork_project       = lookup(each.value.content, "access_connector_subnetwork_project", "") != "" ? lookup(each.value.content, "access_connector_subnetwork_project") : null
  access_connector_vm_type                  = lookup(each.value.content, "access_connector_vm_type", "") != "" ? lookup(each.value.content, "access_connector_vm_type") : null
  access_connector_vm_min_instances         = lookup(each.value.content, "access_connector_vm_min_instances", "") != "" ? lookup(each.value.content, "access_connector_vm_min_instances") : null
  access_connector_vm_max_instances         = lookup(each.value.content, "access_connector_vm_max_instances", "") != "" ? lookup(each.value.content, "access_connector_vm_max_instances") : null
  access_connector_vm_min_throughput        = lookup(each.value.content, "access_connector_vm_min_throughput", "") != "" ? lookup(each.value.content, "access_connector_vm_min_throughput") : null
  access_connector_vm_max_throughput        = lookup(each.value.content, "access_connector_vm_max_throughput", "") != "" ? lookup(each.value.content, "access_connector_vm_max_throughput") : null
  service_networking_connection             = lookup(each.value.content, "service_networking_connection", "") != "" ? lookup(each.value.content, "service_networking_connection") : null
  depends_on                                = [module.gcp_apis_services]
}
