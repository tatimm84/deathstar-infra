# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT


# --------------------------------------------------------------------
# CLOUD LOAD BALANCING
# --------------------------------------------------------------------
locals {
  load_balancing = module.json_lb_reader.parsed_data

  backend = distinct(flatten([
    for item in local.load_balancing : [
      for i in range(length(lookup(item.content, "backend_services", []))) : {
        file    = item.source
        count   = i
        content = item.content
      }
    ]
  ]))

  neg = distinct(flatten([
    for item in local.load_balancing : [
      for i in range(length(lookup(item.content, "negs", []))) : {
        file    = item.source
        count   = i
        content = item.content
      }
    ]
  ]))

  instance_group = distinct(flatten([
    for item in local.load_balancing : [
      for i in range(length(lookup(item.content, "instance_groups", []))) : {
        file    = item.source
        count   = i
        content = item.content
      }
    ]
  ]))

}

module "json_lb_reader" {
  source = "./modules/utils/reader"

  source_path = "${var.SRC_INFRA_PATH}/gcp/auto/cloud_load_balancing/"
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

module "gcp_cloud_load_balancing_main" {
  for_each                              = { for entry in local.load_balancing : "${entry.source}" => entry }
  source                                = "./modules/gcp/cloud_load_balancing"
  gcp_project                           = var.GCP_PROJECT
  gcp_region                            = lookup(each.value.content, "location", "") != "" ? lookup(each.value.content, "location") : var.GCP_REGION
  network                               = lookup(each.value.content, "network", "") != "" ? lookup(each.value.content, "network") : null
  subnetwork                            = lookup(each.value.content, "subnetwork", "") != "" ? lookup(each.value.content, "subnetwork") : null
  forwarding_rule_type                  = lookup(each.value.content, "forwarding_rule_type", "") != "" ? lookup(each.value.content, "forwarding_rule_type") : null
  forwarding_rule                       = lookup(each.value.content, "forwarding_rule", "") != "" ? lookup(each.value.content, "forwarding_rule") : null
  target                                = lookup(each.value.content, "target", "") != "" ? lookup(each.value.content, "target") : null
  all_ports                             = lookup(each.value.content, "all_ports", "") != "" ? lookup(each.value.content, "all_ports") : null
  allow_global_access                   = lookup(each.value.content, "allow_global_access", "") != "" ? lookup(each.value.content, "allow_global_access") : null
  backend_service                       = lookup(each.value.content, "backend_service", "") != "" ? lookup(each.value.content, "backend_service") : null
  forwarding_rule_description           = lookup(each.value.content, "forwarding_rule_description", "") != "" ? lookup(each.value.content, "forwarding_rule_description") : null
  ip_address                            = lookup(each.value.content, "ip_address", "") != "" ? lookup(each.value.content, "ip_address") : null
  ip_protocol                           = lookup(each.value.content, "ip_protocol", "") != "" ? lookup(each.value.content, "ip_protocol") : null
  ip_version                            = lookup(each.value.content, "ip_version", "") != "" ? lookup(each.value.content, "ip_version") : null
  is_mirroring_collector                = lookup(each.value.content, "is_mirroring_collector", "") != "" ? lookup(each.value.content, "is_mirroring_collector") : null
  forwarding_rule_labels                = lookup(each.value.content, "forwarding_rule_labels", {}) != {} ? lookup(each.value.content, "forwarding_rule_labels") : null
  forwarding_rule_load_balancing_scheme = lookup(each.value.content, "forwarding_rule_load_balancing_scheme", "") != "" ? lookup(each.value.content, "forwarding_rule_load_balancing_scheme") : null
  network_tier                          = lookup(each.value.content, "network_tier", "") != "" ? lookup(each.value.content, "network_tier") : null
  port_range                            = lookup(each.value.content, "port_range", "") != "" ? lookup(each.value.content, "port_range") : null
  ports                                 = lookup(each.value.content, "ports", "") != "" ? lookup(each.value.content, "ports") : null
  service_label                         = lookup(each.value.content, "service_label", "") != "" ? lookup(each.value.content, "service_label") : null
  metadata_filters                      = lookup(each.value.content, "metadata_filters", {}) != {} ? [lookup(each.value.content, "metadata_filters")] : []
  service_directory_registrations       = lookup(each.value.content, "service_directory_registrations", {}) != {} ? [lookup(each.value.content, "service_directory_registrations")] : []
  proxy_type                            = lookup(each.value.content, "proxy_type", "") != "" ? lookup(each.value.content, "proxy_type") : null
  proxy                                 = lookup(each.value.content, "proxy", "") != "" ? lookup(each.value.content, "proxy") : null
  certificate_map                       = lookup(each.value.content, "certificate_map", "") != "" ? lookup(each.value.content, "certificate_map") : null
  proxy_description                     = lookup(each.value.content, "proxy_description", "") != "" ? lookup(each.value.content, "proxy_description") : null
  proxy_bind                            = lookup(each.value.content, "proxy_bind", "") != "" ? lookup(each.value.content, "proxy_bind") : null
  proxy_header                          = lookup(each.value.content, "proxy_header", "") != "" ? lookup(each.value.content, "proxy_header") : null
  quic_override                         = lookup(each.value.content, "quic_override", "") != "" ? lookup(each.value.content, "quic_override") : null
  ssl_certificates                      = lookup(each.value.content, "ssl_certificates", "") != "" ? lookup(each.value.content, "ssl_certificates") : null
  ssl_policy                            = lookup(each.value.content, "ssl_policy", "") != "" ? lookup(each.value.content, "ssl_policy") : null
  url_map_type                          = lookup(each.value.content, "url_map_type", "") != "" ? lookup(each.value.content, "url_map_type") : null
  url_map                               = lookup(each.value.content, "url_map", "") != "" ? lookup(each.value.content, "url_map") : null
  default_service                       = lookup(each.value.content, "default_service", "") != "" ? lookup(each.value.content, "default_service") : null
  url_map_description                   = lookup(each.value.content, "url_map_description", "") != "" ? lookup(each.value.content, "url_map_description") : null
  header_action                         = lookup(each.value.content, "header_action", {}) != {} ? [lookup(each.value.content, "header_action")] : []
  host_rule                             = lookup(each.value.content, "host_rule", []) != [] ? lookup(each.value.content, "host_rule") : []
  path_matcher                          = lookup(each.value.content, "path_matcher", [])
  default_route_action                  = lookup(each.value.content, "default_route_action", {}) != {} ? [lookup(each.value.content, "default_route_action")] : []
  default_url_redirect                  = lookup(each.value.content, "default_url_redirect", {}) != {} ? [lookup(each.value.content, "default_url_redirect")] : []
  test                                  = lookup(each.value.content, "test", {}) != {} ? [lookup(each.value.content, "test")] : []

  health_check             = lookup(each.value.content, "health_check", "") != "" ? lookup(each.value.content, "health_check") : null
  check_interval_sec       = lookup(each.value.content, "check_interval_sec", "") != "" ? lookup(each.value.content, "check_interval_sec") : null
  health_check_description = lookup(each.value.content, "health_check_description", "") != "" ? lookup(each.value.content, "health_check_description") : null
  healthy_threshold        = lookup(each.value.content, "healthy_threshold", "") != "" ? lookup(each.value.content, "healthy_threshold") : null
  health_check_timeout_sec = lookup(each.value.content, "health_check_timeout_sec", "") != "" ? lookup(each.value.content, "health_check_timeout_sec") : null
  unhealthy_threshold      = lookup(each.value.content, "unhealthy_threshold", "") != "" ? lookup(each.value.content, "unhealthy_threshold") : null
  http_health_check        = lookup(each.value.content, "http_health_check", {}) != {} ? [lookup(each.value.content, "http_health_check")] : []
  https_health_check       = lookup(each.value.content, "https_health_check", {}) != {} ? [lookup(each.value.content, "https_health_check")] : []
  tcp_health_check         = lookup(each.value.content, "tcp_health_check", {}) != {} ? [lookup(each.value.content, "tcp_health_check")] : []
  ssl_health_check         = lookup(each.value.content, "ssl_health_check", {}) != {} ? [lookup(each.value.content, "ssl_health_check")] : []
  http2_health_check       = lookup(each.value.content, "http2_health_check", {}) != {} ? [lookup(each.value.content, "http2_health_check")] : []
  grpc_health_check        = lookup(each.value.content, "grpc_health_check", {}) != {} ? [lookup(each.value.content, "grpc_health_check")] : []
  health_check_log_config  = lookup(each.value.content, "health_check_log_config", {}) != {} ? [lookup(each.value.content, "health_check_log_config")] : []
  depends_on               = [module.gcp_apis_services, module.gcp_vpc_network, module.gcp_ssl_security, module.gcp_cloud_load_balancing_backend]
}

module "gcp_cloud_load_balancing_backend" {
  for_each                        = { for entry in local.backend : "${entry.file}_${entry.count}" => entry }
  source                          = "./modules/gcp/cloud_load_balancing"
  gcp_project                     = var.GCP_PROJECT
  gcp_region                      = lookup(each.value.content, "location", "") != "" ? lookup(each.value.content, "location") : var.GCP_REGION
  network                         = lookup(each.value.content, "network", "") != "" ? lookup(each.value.content, "network") : null
  backend_type                    = try(each.value.content["backend_services"][each.value.count]["backend_type"], null)
  backend_name                    = try(each.value.content["backend_services"][each.value.count]["backend_name"], null)
  affinity_cookie_ttl_sec         = try(each.value.content["backend_services"][each.value.count]["affinity_cookie_ttl_sec"], null)
  compression_mode                = try(each.value.content["backend_services"][each.value.count]["compression_mode"], null)
  connection_draining_timeout_sec = try(each.value.content["backend_services"][each.value.count]["connection_draining_timeout_sec"], null)
  custom_request_headers          = try(each.value.content["backend_services"][each.value.count]["custom_request_headers"], null)
  custom_response_headers         = try(each.value.content["backend_services"][each.value.count]["custom_response_headers"], null)
  backend_description             = try(each.value.content["backend_services"][each.value.count]["backend_description"], null)
  enable_cdn                      = try(each.value.content["backend_services"][each.value.count]["enable_cdn"], null)
  health_checks                   = try(each.value.content["backend_services"][each.value.count]["health_checks"], null)
  backend_load_balancing_scheme   = try(each.value.content["backend_services"][each.value.count]["backend_load_balancing_scheme"], null)
  locality_lb_policy              = try(each.value.content["backend_services"][each.value.count]["locality_lb_policy"], null)
  port_name                       = try(each.value.content["backend_services"][each.value.count]["port_name"], null)
  protocol                        = try(each.value.content["backend_services"][each.value.count]["protocol"], null)
  session_affinity                = try(each.value.content["backend_services"][each.value.count]["session_affinity"], null)
  security_policy                 = try(each.value.content["backend_services"][each.value.count]["security_policy"], null)
  backend_timeout_sec             = try(each.value.content["backend_services"][each.value.count]["backend_timeout_sec"], null)
  backend                         = try([each.value.content["backend_services"][each.value.count]["backend"]], {})
  circuit_breakers                = try([each.value.content["backend_services"][each.value.count]["circuit_breakers"]], {})
  consistent_hash                 = try([each.value.content["backend_services"][each.value.count]["consistent_hash"]], {})
  cdn_policy                      = try([each.value.content["backend_services"][each.value.count]["cdn_policy"]], {})
  failover_policy                 = try([each.value.content["backend_services"][each.value.count]["failover_policy"]], {})
  iap                             = try([each.value.content["backend_services"][each.value.count]["iap"]], {})
  outlier_detection               = try([each.value.content["backend_services"][each.value.count]["outlier_detection"]], {})
  security_settings               = try([each.value.content["backend_services"][each.value.count]["security_settings"]], {})
  backend_log_config              = try([each.value.content["backend_services"][each.value.count]["backend_log_config"]], {})
  depends_on                      = [module.gcp_apis_services, module.gcp_cloud_load_balancing_neg, module.gcp_cloud_load_balancing_instance_group]
}

module "gcp_cloud_load_balancing_neg" {
  for_each              = { for entry in local.neg : "${entry.file}_${entry.count}" => entry }
  source                = "./modules/gcp/cloud_load_balancing"
  gcp_project           = var.GCP_PROJECT
  gcp_region            = lookup(each.value.content, "location", "") != "" ? lookup(each.value.content, "location") : var.GCP_REGION
  network               = lookup(each.value.content, "network", "") != "" ? lookup(each.value.content, "network") : null
  subnetwork            = lookup(each.value.content, "subnetwork", "") != "" ? lookup(each.value.content, "subnetwork") : null
  neg_type              = try(each.value.content["negs"][each.value.count]["neg_type"], null)
  neg                   = try(each.value.content["negs"][each.value.count]["neg"], null)
  network_endpoint_type = try(each.value.content["negs"][each.value.count]["network_endpoint_type"], null)
  default_port          = try(each.value.content["negs"][each.value.count]["default_port"], null)
  neg_description       = try(each.value.content["negs"][each.value.count]["neg_description"], null)
  psc_target_service    = try(each.value.content["negs"][each.value.count]["psc_target_service"], null)
  app_engine            = try([each.value.content["negs"][each.value.count]["app_engine"]], {})
  cloud_run             = try([each.value.content["negs"][each.value.count]["cloud_run"]], {})
  cloud_function        = try([each.value.content["negs"][each.value.count]["cloud_function"]], {})
  depends_on            = [module.gcp_apis_services, module.gcp_cloud_run, module.gcp_cloud_function]
}

module "gcp_cloud_load_balancing_instance_group" {
  for_each                   = { for entry in local.instance_group : "${entry.file}_${entry.count}" => entry }
  source                     = "./modules/gcp/cloud_load_balancing"
  gcp_project                = var.GCP_PROJECT
  gcp_zone                   = lookup(each.value.content, "zone", "") != "" ? lookup(each.value.content, "zone") : "${var.GCP_REGION}-b"
  network                    = lookup(each.value.content, "network", "") != "" ? lookup(each.value.content, "network") : null
  instance_group             = try(each.value.content["instance_groups"][each.value.count]["instance_group"], null)
  instance_group_description = try(each.value.content["instance_groups"][each.value.count]["instance_group_description"], null)
  instances                  = try(each.value.content["instance_groups"][each.value.count]["instances"], [])
  named_port                 = try(each.value.content["instance_groups"][each.value.count]["named_port"], [{}])
  depends_on                 = [module.gcp_apis_services, module.gcp_compute_engine_instance]
}
