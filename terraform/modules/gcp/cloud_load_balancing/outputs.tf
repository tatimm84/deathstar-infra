# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# OUTPUTS
# --------------------------------------------------------------------
output "global_forwarding_rule_id" {
  description = "Forwarding rule global id"
  value       = length(google_compute_global_forwarding_rule.global_forwarding_rule) > 0 ? google_compute_global_forwarding_rule.global_forwarding_rule[0].id : null
}
output "global_forwarding_rule_name" {
  description = "Forwarding rule global name"
  value       = length(google_compute_global_forwarding_rule.global_forwarding_rule) > 0 ? google_compute_global_forwarding_rule.global_forwarding_rule[0].name : null
}
output "global_forwarding_rule_self_link" {
  description = "Forwarding rule global self link"
  value       = length(google_compute_global_forwarding_rule.global_forwarding_rule) > 0 ? google_compute_global_forwarding_rule.global_forwarding_rule[0].self_link : null
}
output "regional_forwarding_rule_id" {
  description = "Forwarding rule regional id"
  value       = length(google_compute_forwarding_rule.regional_forwarding_rule) > 0 ? google_compute_forwarding_rule.regional_forwarding_rule[0].id : null
}
output "regional_forwarding_rule_name" {
  description = "Forwarding rule regional name"
  value       = length(google_compute_forwarding_rule.regional_forwarding_rule) > 0 ? google_compute_forwarding_rule.regional_forwarding_rule[0].name : null
}
output "regional_forwarding_rule_self_link" {
  description = "Forwarding rule regional self link"
  value       = length(google_compute_forwarding_rule.regional_forwarding_rule) > 0 ? google_compute_forwarding_rule.regional_forwarding_rule[0].self_link : null
}
output "https_proxy_id" {
  description = "Proxy https id"
  value       = length(google_compute_target_https_proxy.https_proxy) > 0 ? google_compute_target_https_proxy.https_proxy[0].id : null
}
output "https_proxy_name" {
  description = "Proxy https name"
  value       = length(google_compute_target_https_proxy.https_proxy) > 0 ? google_compute_target_https_proxy.https_proxy[0].name : null
}
output "https_proxy_self_link" {
  description = "Proxy https self link"
  value       = length(google_compute_target_https_proxy.https_proxy) > 0 ? google_compute_target_https_proxy.https_proxy[0].self_link : null
}
output "http_proxy_id" {
  description = "Proxy http id"
  value       = length(google_compute_target_http_proxy.http_proxy) > 0 ? google_compute_target_http_proxy.http_proxy[0].id : null
}
output "http_proxy_name" {
  description = "Proxy http name"
  value       = length(google_compute_target_http_proxy.http_proxy) > 0 ? google_compute_target_http_proxy.http_proxy[0].name : null
}
output "http_proxy_self_link" {
  description = "Proxy http self link"
  value       = length(google_compute_target_http_proxy.http_proxy) > 0 ? google_compute_target_http_proxy.http_proxy[0].self_link : null
}
output "ssl_proxy_id" {
  description = "Proxy ssl id"
  value       = length(google_compute_target_ssl_proxy.ssl_proxy) > 0 ? google_compute_target_ssl_proxy.ssl_proxy[0].id : null
}
output "ssl_proxy_name" {
  description = "Proxy ssl name"
  value       = length(google_compute_target_ssl_proxy.ssl_proxy) > 0 ? google_compute_target_ssl_proxy.ssl_proxy[0].name : null
}
output "ssl_proxy_self_link" {
  description = "Proxy ssl self link"
  value       = length(google_compute_target_ssl_proxy.ssl_proxy) > 0 ? google_compute_target_ssl_proxy.ssl_proxy[0].self_link : null
}
output "tcp_proxy_id" {
  description = "Proxy tcp id"
  value       = length(google_compute_target_tcp_proxy.tcp_proxy) > 0 ? google_compute_target_tcp_proxy.tcp_proxy[0].id : null
}
output "tcp_proxy_name" {
  description = "Proxy tcp name"
  value       = length(google_compute_target_tcp_proxy.tcp_proxy) > 0 ? google_compute_target_tcp_proxy.tcp_proxy[0].name : null
}
output "tcp_proxy_self_link" {
  description = "Proxy tcp self link"
  value       = length(google_compute_target_tcp_proxy.tcp_proxy) > 0 ? google_compute_target_tcp_proxy.tcp_proxy[0].self_link : null
}
output "global_url_map_id" {
  description = "Url map global id"
  value       = length(google_compute_url_map.global_url_map) > 0 ? google_compute_url_map.global_url_map[0].id : null
}
output "global_url_map_name" {
  description = "Url map global name"
  value       = length(google_compute_url_map.global_url_map) > 0 ? google_compute_url_map.global_url_map[0].name : null
}
output "global_url_map_self_link" {
  description = "Url map global self link"
  value       = length(google_compute_url_map.global_url_map) > 0 ? google_compute_url_map.global_url_map[0].self_link : null
}
output "regional_url_map_id" {
  description = "Url map regional id"
  value       = length(google_compute_region_url_map.regional_url_map) > 0 ? google_compute_region_url_map.regional_url_map[0].id : null
}
output "regional_url_map_name" {
  description = "Url map regional name"
  value       = length(google_compute_region_url_map.regional_url_map) > 0 ? google_compute_region_url_map.regional_url_map[0].name : null
}
output "regional_url_map_self_link" {
  description = "Url map regional self link"
  value       = length(google_compute_region_url_map.regional_url_map) > 0 ? google_compute_region_url_map.regional_url_map[0].self_link : null
}
output "global_backend_id" {
  description = "Backend service global id"
  value       = length(google_compute_backend_service.global_backend) > 0 ? google_compute_backend_service.global_backend[0].id : null
}
output "global_backend_name" {
  description = "Backend service global name"
  value       = length(google_compute_backend_service.global_backend) > 0 ? google_compute_backend_service.global_backend[0].name : null
}
output "global_backend_link" {
  description = "Backend service global self link"
  value       = length(google_compute_backend_service.global_backend) > 0 ? google_compute_backend_service.global_backend[0].self_link : null
}
output "regional_backend_id" {
  description = "Backend service regional id"
  value       = length(google_compute_region_backend_service.regional_backend) > 0 ? google_compute_region_backend_service.regional_backend[0].id : null
}
output "regional_backend_name" {
  description = "Backend service regional name"
  value       = length(google_compute_region_backend_service.regional_backend) > 0 ? google_compute_region_backend_service.regional_backend[0].name : null
}
output "regional_backend_link" {
  description = "Backend service regional self link"
  value       = length(google_compute_region_backend_service.regional_backend) > 0 ? google_compute_region_backend_service.regional_backend[0].self_link : null
}
output "health_check_id" {
  description = "Health check id"
  value       = length(google_compute_health_check.health_check) > 0 ? google_compute_health_check.health_check[0].id : null
}
output "health_check_name" {
  description = "Health check name"
  value       = length(google_compute_health_check.health_check) > 0 ? google_compute_health_check.health_check[0].name : null
}
output "health_check_link" {
  description = "Health check self link"
  value       = length(google_compute_health_check.health_check) > 0 ? google_compute_health_check.health_check[0].self_link : null
}
output "global_neg_id" {
  description = "Network endpoint group global id"
  value       = length(google_compute_global_network_endpoint_group.global_neg) > 0 ? google_compute_global_network_endpoint_group.global_neg[0].id : null
}
output "global_neg_name" {
  description = "Network endpoint group global name"
  value       = length(google_compute_global_network_endpoint_group.global_neg) > 0 ? google_compute_global_network_endpoint_group.global_neg[0].name : null
}
output "global_neg_link" {
  description = "Network endpoint group global self link"
  value       = length(google_compute_global_network_endpoint_group.global_neg) > 0 ? google_compute_global_network_endpoint_group.global_neg[0].self_link : null
}
output "regional_neg_id" {
  description = "Network endpoint group regional id"
  value       = length(google_compute_region_network_endpoint_group.regional_neg) > 0 ? google_compute_region_network_endpoint_group.regional_neg[0].id : null
}
output "regional_neg_name" {
  description = "Network endpoint group regional name"
  value       = length(google_compute_region_network_endpoint_group.regional_neg) > 0 ? google_compute_region_network_endpoint_group.regional_neg[0].name : null
}
output "regional_neg_link" {
  description = "Network endpoint group regional self link"
  value       = length(google_compute_region_network_endpoint_group.regional_neg) > 0 ? google_compute_region_network_endpoint_group.regional_neg[0].self_link : null
}
output "instance_group_id" {
  description = "Compute engine instance group id"
  value       = length(google_compute_instance_group.instance_group) > 0 ? google_compute_instance_group.instance_group[0].id : null
}
output "instance_group_name" {
  description = "Compute engine instance group name"
  value       = length(google_compute_instance_group.instance_group) > 0 ? google_compute_instance_group.instance_group[0].name : null
}
output "instance_group_self_link" {
  description = "Compute engine instance group self link"
  value       = length(google_compute_instance_group.instance_group) > 0 ? google_compute_instance_group.instance_group[0].self_link : null
}
