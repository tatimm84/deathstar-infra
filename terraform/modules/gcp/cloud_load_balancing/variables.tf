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
variable "gcp_zone" {
  type        = string
  description = "GCP region"
  default     = "southamerica-east1-b"
}

# --------------------------------------------------------------------
# NETWORK / SUBNETWORK
# --------------------------------------------------------------------
variable "network" {
  type        = string
  description = "Load balancing network"
  default     = null
}
variable "subnetwork" {
  type        = string
  description = "Load balancing subnetwork"
  default     = null
}
# --------------------------------------------------------------------
# CLOUD LOAD BALANCING - NETWORK SERVICES - FRONTENDS - FORWARDING RULE
# --------------------------------------------------------------------
variable "forwarding_rule_type" {
  type        = string
  description = "Forwarding rule type"
  default     = null
}
variable "forwarding_rule" {
  type        = string
  description = "Forwarding rule name"
  default     = null
}
variable "target" {
  type        = string
  description = "Forwarding rule target"
  default     = null
}
variable "all_ports" {
  type        = bool
  description = "Forwarding rule all ports"
  default     = null
}
variable "allow_global_access" {
  type        = bool
  description = "Forwarding rule allow global access"
  default     = null
}
variable "backend_service" {
  type        = string
  description = "Forwarding rule backend service"
  default     = null
}
variable "forwarding_rule_description" {
  type        = string
  description = "Forwarding rule description"
  default     = null
}
variable "ip_address" {
  type        = string
  description = "Forwarding rule ip address"
  default     = null
}
variable "ip_protocol" {
  type        = string
  description = "Forwarding rule ip protocol"
  default     = null
}
variable "ip_version" {
  type        = string
  description = "Forwarding rule ip version"
  default     = null
}
variable "is_mirroring_collector" {
  type        = bool
  description = "Forwarding rule is mirroring collector"
  default     = null
}
variable "forwarding_rule_labels" {
  type        = map(string)
  description = "Forwarding rule labels"
  default     = null
}
variable "forwarding_rule_load_balancing_scheme" {
  type        = string
  description = "Forwarding rule load balancing scheme"
  default     = null
}
variable "network_tier" {
  type        = string
  description = "Forwarding rule network tier"
  default     = null
}
variable "port_range" {
  type        = string
  description = "Forwarding rule port range"
  default     = null
}
variable "ports" {
  type        = set(string)
  description = "Forwarding rule ports"
  default     = null
}
variable "service_label" {
  type        = string
  description = "Forwarding rule service label"
  default     = null
}
variable "metadata_filters" {
  description = "Forwarding rule metadata filters"
  default     = null
}
variable "service_directory_registrations" {
  description = "Forwarding rule service directory registrations"
  default     = null
}

# --------------------------------------------------------------------
# CLOUD LOAD BALANCING - NETWORK SERVICES - FRONTENDS - PROXY
# --------------------------------------------------------------------
variable "proxy_type" {
  type        = string
  description = "Proxy type"
  default     = null
}
variable "proxy" {
  type        = string
  description = "Proxy name"
  default     = null
}
variable "certificate_map" {
  type        = string
  description = "Proxy certificate map"
  default     = null
}
variable "proxy_description" {
  type        = string
  description = "Proxy description"
  default     = null
}
variable "proxy_bind" {
  type        = bool
  description = "Proxy bind"
  default     = null
}
variable "proxy_header" {
  type        = string
  description = "Proxy header"
  default     = null
}
variable "quic_override" {
  type        = string
  description = "Proxy quic_override"
  default     = null
}
variable "ssl_certificates" {
  type        = list(string)
  description = "Proxy ssl certificates"
  default     = null
}
variable "ssl_policy" {
  type        = string
  description = "Proxy ssl policy"
  default     = null
}

# --------------------------------------------------------------------
# CLOUD LOAD BALANCING - NETWORK SERVICES - LOAD BALANCERS - URL MAP
# --------------------------------------------------------------------
variable "url_map_type" {
  type        = string
  description = "Url map type"
  default     = null
}
variable "url_map" {
  type        = string
  description = "Url map name"
  default     = null
}
variable "default_service" {
  type        = string
  description = "Url map default service"
  default     = null
}
variable "url_map_description" {
  type        = string
  description = "Url map description"
  default     = null
}
variable "header_action" {
  description = "Url map header action"
  default     = null
}
variable "host_rule" {
  description = "Url map host rule"
  default     = null
}
variable "path_matcher" {
  description = "Url map path matcher"
  default     = null
}
variable "route_rules" {
  description = "Url map route rules"
  default     = null
}
variable "default_route_action" {
  description = "Url map default route action"
  default     = null
}
variable "default_url_redirect" {
  description = "Url map default url redirect"
  default     = null
}
variable "test" {
  description = "Url map test"
  default     = null
}

# --------------------------------------------------------------------
# CLOUD LOAD BALANCING - NETWORK SERVICES - BACKENDS - BACKEND SERVICE
# --------------------------------------------------------------------
variable "backend_type" {
  type        = string
  description = "Backend service type"
  default     = null
}
variable "backend_name" {
  type        = string
  description = "Backend service name"
  default     = null
}
variable "affinity_cookie_ttl_sec" {
  type        = number
  description = "Backend service affinity cookie ttl sec"
  default     = null
}
variable "compression_mode" {
  type        = string
  description = "Backend service compression mode"
  default     = null
}
variable "connection_draining_timeout_sec" {
  type        = number
  description = "Backend service connection draining timeout sec"
  default     = null
}
variable "custom_request_headers" {
  type        = set(string)
  description = "Backend service custom request headers"
  default     = null
}
variable "custom_response_headers" {
  type        = set(string)
  description = "Backend service custom response headers"
  default     = null
}
variable "backend_description" {
  type        = string
  description = "Backend service description"
  default     = null
}
variable "enable_cdn" {
  type        = bool
  description = "Backend service enable cdn"
  default     = null
}
variable "health_checks" {
  type        = set(string)
  description = "Backend service health checks"
  default     = null
}
variable "backend_load_balancing_scheme" {
  type        = string
  description = "Backend service load balancing scheme"
  default     = null
}
variable "locality_lb_policy" {
  type        = string
  description = "Backend service locality lb policy"
  default     = null
}
variable "port_name" {
  type        = string
  description = "Backend service port name"
  default     = null
}
variable "protocol" {
  type        = string
  description = "Backend service protocol"
  default     = null
}
variable "session_affinity" {
  type        = string
  description = "Backend service session affinity"
  default     = null
}
variable "security_policy" {
  type        = string
  description = "Backend service security policy"
  default     = null
}
variable "backend_timeout_sec" {
  type        = number
  description = "Backend service timeout sec"
  default     = null
}
variable "backend" {
  description = "Backend service backend"
  default     = null
}
variable "circuit_breakers" {
  description = "Backend service circuit breakers"
  default     = null
}
variable "consistent_hash" {
  description = "Backend service consistent hash"
  default     = null
}
variable "cdn_policy" {
  description = "Backend service cdn policy"
  default     = null
}
variable "failover_policy" {
  description = "Backend service failover policy"
  default     = null
}
variable "iap" {
  description = "Backend service iap"
  default     = null
}
variable "outlier_detection" {
  description = "Backend service outlier detection"
  default     = null
}
variable "security_settings" {
  description = "Backend service security settings"
  default     = null
}
variable "backend_log_config" {
  description = "Backend service log config"
  default     = null
}

# --------------------------------------------------------------------
# CLOUD LOAD BALANCING - NETWORK SERVICES - BACKENDS - HEALTH CHECK
# --------------------------------------------------------------------
variable "health_check" {
  type        = string
  description = "Health check name"
  default     = null
}
variable "check_interval_sec" {
  type        = number
  description = "Health check check interval sec"
  default     = null
}
variable "health_check_description" {
  type        = string
  description = "Health check description"
  default     = null
}
variable "healthy_threshold" {
  type        = number
  description = "Health check healthy threshold"
  default     = null
}
variable "health_check_timeout_sec" {
  type        = number
  description = "Health check timeout sec"
  default     = null
}
variable "unhealthy_threshold" {
  type        = number
  description = "Health check unhealthy threshold"
  default     = null
}
variable "http_health_check" {
  description = "Health check http"
  default     = null
}
variable "https_health_check" {
  description = "Health check https"
  default     = null
}
variable "tcp_health_check" {
  description = "Health check tcp"
  default     = null
}
variable "ssl_health_check" {
  description = "Health check ssl"
  default     = null
}
variable "http2_health_check" {
  description = "Health check http2"
  default     = null
}
variable "grpc_health_check" {
  description = "Health check grpc"
  default     = null
}
variable "health_check_log_config" {
  description = "Health check log config"
  default     = null
}

# --------------------------------------------------------------------
# CLOUD LOAD BALANCING - NETWORK SERVICES - BACKENDS - NETWORK ENDPOINT GROUP
# --------------------------------------------------------------------
variable "neg_type" {
  type        = string
  description = "Network endpoint group type"
  default     = null
}
variable "neg" {
  type        = string
  description = "Network endpoint group name"
  default     = null
}
variable "network_endpoint_type" {
  type        = string
  description = "Network endpoint group network endpoint type"
  default     = null
}
variable "default_port" {
  type        = string
  description = "Network endpoint group default port"
  default     = null
}
variable "neg_description" {
  type        = string
  description = "Network endpoint group description"
  default     = null
}
variable "psc_target_service" {
  type        = string
  description = "Network endpoint group psc target service"
  default     = null
}
variable "app_engine" {
  description = "Network endpoint group app engine"
  default     = null
}
variable "cloud_run" {
  description = "Network endpoint group cloud run"
  default     = null
}
variable "cloud_function" {
  description = "Network endpoint group cloud function"
  default     = null
}

# --------------------------------------------------------------------
# COMPUTE ENGINE - INSTANCE GROUP
# --------------------------------------------------------------------
variable "instance_group" {
  type        = string
  description = "Compute engine instance group name"
  default     = null
}
variable "instance_group_description" {
  type        = string
  description = "Compute engine instance group description"
  default     = null
}
variable "instances" {
  type        = list(string)
  description = "Compute engine instance resource policies"
  default     = null
}
variable "named_port" {
  description = "Compute engine instance named port"
  default     = []
}
