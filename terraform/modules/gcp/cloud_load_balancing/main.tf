# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# CLOUD LOAD BALANCING - NETWORK SERVICES - FRONTENDS - FORWARDING RULE
# --------------------------------------------------------------------
resource "google_compute_global_forwarding_rule" "global_forwarding_rule" {
  count                 = var.forwarding_rule_type == "global" ? 1 : 0
  project               = var.gcp_project
  name                  = var.forwarding_rule
  target                = var.target
  description           = var.forwarding_rule_description
  ip_address            = var.ip_address
  ip_protocol           = var.ip_protocol
  ip_version            = var.ip_version
  labels                = var.forwarding_rule_labels
  load_balancing_scheme = var.forwarding_rule_load_balancing_scheme
  network               = var.network
  # no_automate_dns_zone  = var.no_automate_dns_zone
  port_range = var.port_range
  # source_ip_ranges      = var.source_ip_ranges
  # subnetwork            = var.subnetwork
  depends_on = [google_compute_target_https_proxy.https_proxy, google_compute_target_http_proxy.http_proxy, google_compute_target_tcp_proxy.tcp_proxy]

  dynamic "metadata_filters" {
    for_each = var.metadata_filters
    content {
      filter_match_criteria = lookup(metadata_filters.value, "filter_match_criteria")
      dynamic "filter_labels" {
        for_each = lookup(metadata_filters.value, "filter_labels", {}) != {} ? [lookup(metadata_filters.value, "filter_labels")] : []
        content {
          name  = lookup(filter_labels.value, "name", null)
          value = lookup(filter_labels.value, "value", null)
        }
      }
    }
  }
}

resource "google_compute_forwarding_rule" "regional_forwarding_rule" {
  count               = var.forwarding_rule_type == "regional" ? 1 : 0
  project             = var.gcp_project
  region              = var.gcp_region
  name                = var.forwarding_rule
  all_ports           = var.all_ports
  allow_global_access = var.allow_global_access
  # allow_psc_global_access = var.allow_psc_global_access
  backend_service = var.backend_service
  description     = var.forwarding_rule_description
  ip_address      = var.ip_address
  ip_protocol     = var.ip_protocol
  # ip_version            = var.ip_version
  is_mirroring_collector = var.is_mirroring_collector
  labels                 = var.forwarding_rule_labels
  load_balancing_scheme  = var.forwarding_rule_load_balancing_scheme
  network                = var.network
  network_tier           = var.network_tier
  # no_automate_dns_zone    = var.no_automate_dns_zone
  port_range    = var.port_range
  ports         = var.ports
  service_label = var.service_label
  subnetwork    = var.subnetwork
  # source_ip_ranges        = var.source_ip_ranges
  target     = var.target
  depends_on = [google_compute_target_https_proxy.https_proxy, google_compute_region_target_https_proxy.https_regional_proxy, google_compute_target_http_proxy.http_proxy, google_compute_target_tcp_proxy.tcp_proxy]

  dynamic "service_directory_registrations" {
    for_each = var.service_directory_registrations
    content {
      namespace = lookup(service_directory_registrations.value, "namespace", null)
      service   = lookup(service_directory_registrations.value, "service", null)
    }
  }
}

# --------------------------------------------------------------------
# CLOUD LOAD BALANCING - NETWORK SERVICES - FRONTENDS - PROXY
# --------------------------------------------------------------------
resource "google_compute_target_https_proxy" "https_proxy" {
  count   = var.proxy_type == "https" ? 1 : 0
  project = var.gcp_project
  name    = var.proxy
  url_map = var.url_map
  # certificate_manager_certificates = var.certificate_manager_certificates
  certificate_map = var.certificate_map
  description     = var.proxy_description
  # http_keep_alive_timeout_sec      = var.http_keep_alive_timeout_sec
  proxy_bind    = var.proxy_bind
  quic_override = var.quic_override
  # server_tls_policy                = var.server_tls_policy
  ssl_certificates = var.ssl_certificates
  ssl_policy       = var.ssl_policy
  depends_on       = [google_compute_url_map.global_url_map, google_compute_region_url_map.regional_url_map]
}

resource "google_compute_region_target_https_proxy" "https_regional_proxy" {
  count   = var.proxy_type == "https-regional" ? 1 : 0
  project = var.gcp_project
  region  = var.gcp_region
  name    = var.proxy
  url_map = var.url_map

  description = var.proxy_description

  ssl_certificates = var.ssl_certificates
  ssl_policy       = var.ssl_policy
  depends_on       = [google_compute_region_url_map.regional_url_map]
}

resource "google_compute_target_http_proxy" "http_proxy" {
  count       = var.proxy_type == "http" ? 1 : 0
  project     = var.gcp_project
  name        = var.proxy
  url_map     = var.url_map
  description = var.proxy_description
  # http_keep_alive_timeout_sec = var.http_keep_alive_timeout_sec
  proxy_bind = var.proxy_bind
  depends_on = [google_compute_url_map.global_url_map, google_compute_region_url_map.regional_url_map]
}

resource "google_compute_target_ssl_proxy" "ssl_proxy" {
  count            = var.proxy_type == "ssl" ? 1 : 0
  project          = var.gcp_project
  name             = var.proxy
  backend_service  = var.backend_service
  certificate_map  = var.certificate_map
  description      = var.proxy_description
  proxy_header     = var.proxy_header
  ssl_certificates = var.ssl_certificates
  ssl_policy       = var.ssl_policy
  depends_on       = [google_compute_backend_service.global_backend, google_compute_region_backend_service.regional_backend]
}

resource "google_compute_target_tcp_proxy" "tcp_proxy" {
  count           = var.proxy_type == "tcp" ? 1 : 0
  project         = var.gcp_project
  name            = var.proxy
  backend_service = var.backend_service
  description     = var.proxy_description
  proxy_bind      = var.proxy_bind
  proxy_header    = var.proxy_header
  depends_on      = [google_compute_backend_service.global_backend, google_compute_region_backend_service.regional_backend]
}

# --------------------------------------------------------------------
# CLOUD LOAD BALANCING - NETWORK SERVICES - LOAD BALANCERS - URL MAP
# --------------------------------------------------------------------
resource "google_compute_url_map" "global_url_map" {
  count           = var.url_map_type == "global" ? 1 : 0
  project         = var.gcp_project
  name            = var.url_map
  default_service = var.default_service
  description     = var.url_map_description
  depends_on      = [google_compute_backend_service.global_backend, google_compute_region_backend_service.regional_backend]

  dynamic "header_action" {
    for_each = var.header_action
    content {
      request_headers_to_remove  = lookup(header_action.value, "request_headers_to_remove", null)
      response_headers_to_remove = lookup(header_action.value, "response_headers_to_remove", null)

      dynamic "request_headers_to_add" {
        for_each = lookup(header_action.value, "request_headers_to_add", {}) != {} ? [lookup(header_action.value, "request_headers_to_add")] : []
        content {
          header_name  = lookup(request_headers_to_add.value, "header_name", null)
          header_value = lookup(request_headers_to_add.value, "header_value", null)
          replace      = lookup(request_headers_to_add.value, "replace", null)
        }
      }
      dynamic "response_headers_to_add" {
        for_each = lookup(header_action.value, "response_headers_to_add", {}) != {} ? [lookup(header_action.value, "response_headers_to_add")] : []
        content {
          header_name  = lookup(response_headers_to_add.value, "header_name", null)
          header_value = lookup(response_headers_to_add.value, "header_value", null)
          replace      = lookup(response_headers_to_add.value, "replace", null)
        }
      }
    }
  }
  dynamic "host_rule" {
    for_each = var.host_rule
    content {
      description  = lookup(host_rule.value, "description", null)
      hosts        = lookup(host_rule.value, "hosts", null)
      path_matcher = lookup(host_rule.value, "path_matcher", null)
    }
  }
  dynamic "path_matcher" {
    for_each = var.path_matcher
    content {
      name            = lookup(path_matcher.value, "name", null)
      default_service = lookup(path_matcher.value, "default_service", null)
      description     = lookup(path_matcher.value, "description", null)

      dynamic "default_url_redirect" {
        for_each = lookup(path_matcher.value, "default_url_redirect", {}) != {} ? [lookup(path_matcher.value, "default_url_redirect")] : []
        content {
          host_redirect          = lookup(default_url_redirect.value, "host_redirect", null)
          https_redirect         = lookup(default_url_redirect.value, "https_redirect", null)
          path_redirect          = lookup(default_url_redirect.value, "path_redirect", null)
          prefix_redirect        = lookup(default_url_redirect.value, "prefix_redirect", null)
          redirect_response_code = lookup(default_url_redirect.value, "redirect_response_code", null)
          strip_query            = lookup(default_url_redirect.value, "strip_query", null)
        }
      }
      dynamic "default_route_action" {
        for_each = lookup(path_matcher.value, "default_route_action", {}) != {} ? [lookup(path_matcher.value, "default_route_action")] : []
        content {
          dynamic "weighted_backend_services" {
            for_each = lookup(default_route_action.value, "weighted_backend_services", {}) != {} ? [lookup(default_route_action.value, "weighted_backend_services")] : []
            content {
              backend_service = lookup(weighted_backend_services.value, "backend_service", null)
              weight          = lookup(weighted_backend_services.value, "weight", null)
              dynamic "header_action" {
                for_each = lookup(weighted_backend_services.value, "header_action", {}) != {} ? [lookup(weighted_backend_services.value, "header_action")] : []
                content {
                  request_headers_to_remove  = lookup(header_action.value, "request_headers_to_remove", null)
                  response_headers_to_remove = lookup(header_action.value, "response_headers_to_remove", null)

                  dynamic "request_headers_to_add" {
                    for_each = lookup(header_action.value, "request_headers_to_add", {}) != {} ? [lookup(header_action.value, "request_headers_to_add")] : []
                    content {
                      header_name  = lookup(request_headers_to_add.value, "header_name", null)
                      header_value = lookup(request_headers_to_add.value, "header_value", null)
                      replace      = lookup(request_headers_to_add.value, "replace", null)
                    }
                  }
                  dynamic "response_headers_to_add" {
                    for_each = lookup(header_action.value, "response_headers_to_add", {}) != {} ? [lookup(header_action.value, "response_headers_to_add")] : []
                    content {
                      header_name  = lookup(response_headers_to_add.value, "header_name", null)
                      header_value = lookup(response_headers_to_add.value, "header_value", null)
                      replace      = lookup(response_headers_to_add.value, "replace", null)
                    }
                  }
                }
              }
            }
          }
          dynamic "url_rewrite" {
            for_each = lookup(default_route_action.value, "url_rewrite", {}) != {} ? [lookup(default_route_action.value, "url_rewrite")] : []
            content {
              path_prefix_rewrite = lookup(url_rewrite.value, "path_prefix_rewrite", null)
              host_rewrite        = lookup(url_rewrite.value, "host_rewrite", null)
            }
          }
          dynamic "timeout" {
            for_each = lookup(default_route_action.value, "timeout", {}) != {} ? [lookup(default_route_action.value, "timeout")] : []
            content {
              seconds = lookup(timeout.value, "seconds", null)
              nanos   = lookup(timeout.value, "nanos", null)
            }
          }
          dynamic "retry_policy" {
            for_each = lookup(default_route_action.value, "retry_policy", {}) != {} ? [lookup(default_route_action.value, "retry_policy")] : []
            content {
              retry_conditions = lookup(retry_policy.value, "retry_conditions", null)
              num_retries      = lookup(retry_policy.value, "num_retries", null)
              dynamic "per_try_timeout" {
                for_each = lookup(retry_policy.value, "per_try_timeout", {}) != {} ? [lookup(retry_policy.value, "per_try_timeout")] : []
                content {
                  seconds = lookup(per_try_timeout.value, "seconds", null)
                  nanos   = lookup(per_try_timeout.value, "nanos", null)
                }
              }
            }
          }
          dynamic "request_mirror_policy" {
            for_each = lookup(default_route_action.value, "request_mirror_policy", {}) != {} ? [lookup(default_route_action.value, "request_mirror_policy")] : []
            content {
              backend_service = lookup(request_mirror_policy.value, "backend_service", null)
            }
          }
          dynamic "cors_policy" {
            for_each = lookup(default_route_action.value, "cors_policy", {}) != {} ? [lookup(default_route_action.value, "cors_policy")] : []
            content {
              allow_origins        = lookup(cors_policy.value, "allow_origins", null)
              allow_origin_regexes = lookup(cors_policy.value, "allow_origin_regexes", null)
              allow_methods        = lookup(cors_policy.value, "allow_methods", null)
              allow_headers        = lookup(cors_policy.value, "allow_headers", null)
              expose_headers       = lookup(cors_policy.value, "expose_headers", null)
              max_age              = lookup(cors_policy.value, "max_age", null)
              allow_credentials    = lookup(cors_policy.value, "allow_credentials", null)
              disabled             = lookup(cors_policy.value, "disabled", null)
            }
          }
          dynamic "fault_injection_policy" {
            for_each = lookup(default_route_action.value, "fault_injection_policy", {}) != {} ? [lookup(default_route_action.value, "fault_injection_policy")] : []
            content {
              dynamic "abort" {
                for_each = lookup(fault_injection_policy.value, "abort", {}) != {} ? [lookup(fault_injection_policy.value, "abort")] : []
                content {
                  http_status = lookup(abort.value, "http_status", null)
                  percentage  = lookup(abort.value, "percentage", null)
                }
              }
              dynamic "delay" {
                for_each = lookup(fault_injection_policy.value, "delay", {}) != {} ? [lookup(fault_injection_policy.value, "delay")] : []
                content {
                  percentage = lookup(delay.value, "percentage", null)
                  dynamic "fixed_delay" {
                    for_each = lookup(delay.value, "fixed_delay", {}) != {} ? [lookup(delay.value, "fixed_delay")] : []
                    content {
                      nanos   = lookup(fixed_delay.value, "nanos", null)
                      seconds = lookup(fixed_delay.value, "seconds", null)
                    }
                  }
                }
              }
            }
          }
        }
      }
      dynamic "header_action" {
        for_each = lookup(path_matcher.value, "header_action", {}) != {} ? [lookup(path_matcher.value, "header_action")] : []
        content {
          request_headers_to_remove  = lookup(header_action.value, "request_headers_to_remove", null)
          response_headers_to_remove = lookup(header_action.value, "response_headers_to_remove", null)

          dynamic "request_headers_to_add" {
            for_each = lookup(header_action.value, "request_headers_to_add", {}) != {} ? [lookup(header_action.value, "request_headers_to_add")] : []
            content {
              header_name  = lookup(request_headers_to_add.value, "header_name", null)
              header_value = lookup(request_headers_to_add.value, "header_value", null)
              replace      = lookup(request_headers_to_add.value, "replace", null)
            }
          }
          dynamic "response_headers_to_add" {
            for_each = lookup(header_action.value, "response_headers_to_add", {}) != {} ? [lookup(header_action.value, "response_headers_to_add")] : []
            content {
              header_name  = lookup(response_headers_to_add.value, "header_name", null)
              header_value = lookup(response_headers_to_add.value, "header_value", null)
              replace      = lookup(response_headers_to_add.value, "replace", null)
            }
          }
        }
      }
      dynamic "path_rule" {
        for_each = lookup(path_matcher.value, "path_rule", {}) != {} ? [lookup(path_matcher.value, "path_rule")] : []
        content {
          service = lookup(path_rule.value, "service", null)
          paths   = lookup(path_rule.value, "paths", null)
          dynamic "route_action" {
            for_each = lookup(path_rule.value, "route_action", {}) != {} ? [lookup(path_rule.value, "route_action")] : []
            content {
              dynamic "cors_policy" {
                for_each = lookup(route_action.value, "cors_policy", {}) != {} ? [lookup(route_action.value, "cors_policy")] : []
                content {
                  allow_credentials    = lookup(cors_policy.value, "allow_credentials", null)
                  allow_headers        = lookup(cors_policy.value, "allow_headers", null)
                  allow_methods        = lookup(cors_policy.value, "allow_methods", null)
                  allow_origins        = lookup(cors_policy.value, "allow_origins", null)
                  allow_origin_regexes = lookup(cors_policy.value, "allow_origin_regexes", null)
                  disabled             = lookup(cors_policy.value, "disabled", null)
                  expose_headers       = lookup(cors_policy.value, "expose_headers", null)
                  max_age              = lookup(cors_policy.value, "max_age", null)
                }
              }
              dynamic "fault_injection_policy" {
                for_each = lookup(route_action.value, "fault_injection_policy", {}) != {} ? [lookup(route_action.value, "fault_injection_policy")] : []
                content {
                  dynamic "abort" {
                    for_each = lookup(fault_injection_policy.value, "abort", {}) != {} ? [lookup(fault_injection_policy.value, "abort")] : []
                    content {
                      http_status = lookup(abort.value, "http_status", null)
                      percentage  = lookup(abort.value, "percentage", null)
                    }
                  }
                  dynamic "delay" {
                    for_each = lookup(fault_injection_policy.value, "delay", {}) != {} ? [lookup(fault_injection_policy.value, "delay")] : []
                    content {
                      percentage = lookup(delay.value, "percentage", null)
                      dynamic "fixed_delay" {
                        for_each = lookup(delay.value, "fixed_delay", {}) != {} ? [lookup(delay.value, "fixed_delay")] : []
                        content {
                          nanos   = lookup(fixed_delay.value, "nanos", null)
                          seconds = lookup(fixed_delay.value, "seconds", null)
                        }
                      }
                    }
                  }
                }
              }
              dynamic "request_mirror_policy" {
                for_each = lookup(route_action.value, "request_mirror_policy", {}) != {} ? [lookup(route_action.value, "request_mirror_policy")] : []
                content {
                  backend_service = lookup(request_mirror_policy.value, "backend_service", null)
                }
              }
              dynamic "retry_policy" {
                for_each = lookup(route_action.value, "retry_policy", {}) != {} ? [lookup(route_action.value, "retry_policy")] : []
                content {
                  retry_conditions = lookup(retry_policy.value, "retry_conditions", null)
                  num_retries      = lookup(retry_policy.value, "num_retries", null)
                  dynamic "per_try_timeout" {
                    for_each = lookup(retry_policy.value, "per_try_timeout", {}) != {} ? [lookup(retry_policy.value, "per_try_timeout")] : []
                    content {
                      seconds = lookup(per_try_timeout.value, "seconds", null)
                      nanos   = lookup(per_try_timeout.value, "nanos", null)
                    }
                  }
                }
              }
              dynamic "timeout" {
                for_each = lookup(route_action.value, "timeout", {}) != {} ? [lookup(route_action.value, "timeout")] : []
                content {
                  seconds = lookup(timeout.value, "seconds", null)
                  nanos   = lookup(timeout.value, "nanos", null)
                }
              }
              dynamic "url_rewrite" {
                for_each = lookup(route_action.value, "url_rewrite", {}) != {} ? [lookup(route_action.value, "url_rewrite")] : []
                content {
                  host_rewrite        = lookup(url_rewrite.value, "host_rewrite", null)
                  path_prefix_rewrite = lookup(url_rewrite.value, "path_prefix_rewrite", null)
                }
              }
              dynamic "weighted_backend_services" {
                for_each = lookup(route_action.value, "weighted_backend_services", {}) != {} ? [lookup(route_action.value, "weighted_backend_services")] : []
                content {
                  backend_service = lookup(weighted_backend_services.value, "backend_service", null)
                  weight          = lookup(weighted_backend_services.value, "weight", null)
                  dynamic "header_action" {
                    for_each = lookup(weighted_backend_services.value, "header_action", {}) != {} ? [lookup(weighted_backend_services.value, "header_action")] : []
                    content {
                      request_headers_to_remove  = lookup(header_action.value, "request_headers_to_remove", null)
                      response_headers_to_remove = lookup(header_action.value, "response_headers_to_remove", null)

                      dynamic "request_headers_to_add" {
                        for_each = lookup(header_action.value, "request_headers_to_add", {}) != {} ? [lookup(header_action.value, "request_headers_to_add")] : []
                        content {
                          header_name  = lookup(request_headers_to_add.value, "header_name", null)
                          header_value = lookup(request_headers_to_add.value, "header_value", null)
                          replace      = lookup(request_headers_to_add.value, "replace", null)
                        }
                      }
                      dynamic "response_headers_to_add" {
                        for_each = lookup(header_action.value, "response_headers_to_add", {}) != {} ? [lookup(header_action.value, "response_headers_to_add")] : []
                        content {
                          header_name  = lookup(response_headers_to_add.value, "header_name", null)
                          header_value = lookup(response_headers_to_add.value, "header_value", null)
                          replace      = lookup(response_headers_to_add.value, "replace", null)
                        }
                      }
                    }
                  }
                }
              }
            }
          }
          dynamic "url_redirect" {
            for_each = lookup(path_rule.value, "url_redirect", {}) != {} ? [lookup(path_rule.value, "url_redirect")] : []
            content {
              host_redirect          = lookup(url_redirect.value, "host_redirect", null)
              https_redirect         = lookup(url_redirect.value, "https_redirect", null)
              path_redirect          = lookup(url_redirect.value, "path_redirect", null)
              prefix_redirect        = lookup(url_redirect.value, "prefix_redirect", null)
              redirect_response_code = lookup(url_redirect.value, "redirect_response_code", null)
              strip_query            = lookup(url_redirect.value, "strip_query", null)
            }
          }
        }
      }
      dynamic "route_rules" {
        for_each = try(path_matcher.value["route_rules"], {})
        # for_each = lookup(path_matcher.value, "route_rules", {}) != {} ? [lookup(path_matcher.value, "route_rules")] : []
        content {
          priority = lookup(route_rules.value, "priority", null)
          service  = lookup(route_rules.value, "service", null)
          dynamic "url_redirect" {
            for_each = lookup(route_rules.value, "url_redirect", {}) != {} ? [lookup(route_rules.value, "url_redirect")] : []
            content {
              host_redirect          = lookup(url_redirect.value, "host_redirect", null)
              https_redirect         = lookup(url_redirect.value, "https_redirect", null)
              path_redirect          = lookup(url_redirect.value, "path_redirect", null)
              prefix_redirect        = lookup(url_redirect.value, "prefix_redirect", null)
              redirect_response_code = lookup(url_redirect.value, "redirect_response_code", null)
              strip_query            = lookup(url_redirect.value, "strip_query", null)
            }
          }
          dynamic "match_rules" {
            for_each = lookup(route_rules.value, "match_rules", {}) != {} ? [lookup(route_rules.value, "match_rules")] : []
            content {
              full_path_match     = lookup(match_rules.value, "full_path_match", null)
              ignore_case         = lookup(match_rules.value, "ignore_case", null)
              prefix_match        = lookup(match_rules.value, "prefix_match", null)
              regex_match         = lookup(match_rules.value, "regex_match", null)
              path_template_match = lookup(match_rules.value, "path_template_match", null)
              dynamic "metadata_filters" {
                for_each = lookup(match_rules.value, "metadata_filters", {}) != {} ? [lookup(match_rules.value, "metadata_filters")] : []
                content {
                  filter_match_criteria = lookup(metadata_filters.value, "filter_match_criteria", null)
                  dynamic "filter_labels" {
                    for_each = lookup(metadata_filters.value, "filter_labels", {}) != {} ? [lookup(route_rules.value, "filter_labels")] : []
                    content {
                      name  = lookup(filter_labels.value, "name", null)
                      value = lookup(filter_labels.value, "value", null)
                    }
                  }
                }
              }
              dynamic "query_parameter_matches" {
                for_each = lookup(match_rules.value, "query_parameter_matches", {}) != {} ? [lookup(match_rules.value, "query_parameter_matches")] : []
                content {
                  exact_match   = lookup(query_parameter_matches.value, "exact_match", null)
                  name          = lookup(query_parameter_matches.value, "name", null)
                  present_match = lookup(query_parameter_matches.value, "present_match", null)
                  regex_match   = lookup(query_parameter_matches.value, "regex_match", null)
                }
              }
              dynamic "header_matches" {
                for_each = lookup(match_rules.value, "header_matches", {}) != {} ? [lookup(match_rules.value, "header_matches")] : []
                content {
                  exact_match   = lookup(header_matches.value, "exact_match", null)
                  header_name   = lookup(header_matches.value, "header_name", null)
                  invert_match  = lookup(header_matches.value, "invert_match", null)
                  prefix_match  = lookup(header_matches.value, "prefix_match", null)
                  present_match = lookup(header_matches.value, "present_match", null)
                  regex_match   = lookup(header_matches.value, "regex_match", null)
                  suffix_match  = lookup(header_matches.value, "suffix_match", null)
                  dynamic "range_match" {
                    for_each = lookup(header_matches.value, "range_match", {}) != {} ? [lookup(header_matches.value, "range_match")] : []
                    content {
                      range_end   = lookup(range_match.value, "range_end", null)
                      range_start = lookup(range_match.value, "range_start", null)
                    }
                  }
                }
              }
            }
          }
          dynamic "route_action" {
            for_each = lookup(route_rules.value, "route_action", {}) != {} ? [lookup(route_rules.value, "route_action")] : []
            content {
              dynamic "cors_policy" {
                for_each = lookup(route_action.value, "cors_policy", {}) != {} ? [lookup(route_action.value, "cors_policy")] : []
                content {
                  allow_credentials    = lookup(cors_policy.value, "allow_credentials", null)
                  allow_headers        = lookup(cors_policy.value, "allow_headers", null)
                  allow_methods        = lookup(cors_policy.value, "allow_methods", null)
                  allow_origins        = lookup(cors_policy.value, "allow_origins", null)
                  allow_origin_regexes = lookup(cors_policy.value, "allow_origin_regexes", null)
                  disabled             = lookup(cors_policy.value, "disabled", null)
                  expose_headers       = lookup(cors_policy.value, "expose_headers", null)
                  max_age              = lookup(cors_policy.value, "max_age", null)
                }
              }
              dynamic "fault_injection_policy" {
                for_each = lookup(route_action.value, "fault_injection_policy", {}) != {} ? [lookup(route_action.value, "fault_injection_policy")] : []
                content {
                  dynamic "abort" {
                    for_each = lookup(fault_injection_policy.value, "abort", {}) != {} ? [lookup(fault_injection_policy.value, "abort")] : []
                    content {
                      http_status = lookup(abort.value, "http_status", null)
                      percentage  = lookup(abort.value, "percentage", null)
                    }
                  }
                  dynamic "delay" {
                    for_each = lookup(fault_injection_policy.value, "delay", {}) != {} ? [lookup(fault_injection_policy.value, "delay")] : []
                    content {
                      percentage = lookup(delay.value, "percentage", null)
                      dynamic "fixed_delay" {
                        for_each = lookup(delay.value, "fixed_delay", {}) != {} ? [lookup(delay.value, "fixed_delay")] : []
                        content {
                          nanos   = lookup(fixed_delay.value, "nanos", null)
                          seconds = lookup(fixed_delay.value, "seconds", null)
                        }
                      }
                    }
                  }
                }
              }
              dynamic "request_mirror_policy" {
                for_each = lookup(route_action.value, "request_mirror_policy", {}) != {} ? [lookup(route_action.value, "request_mirror_policy")] : []
                content {
                  backend_service = lookup(request_mirror_policy.value, "backend_service", null)
                }
              }
              dynamic "retry_policy" {
                for_each = lookup(route_action.value, "retry_policy", {}) != {} ? [lookup(route_action.value, "retry_policy")] : []
                content {
                  retry_conditions = lookup(retry_policy.value, "retry_conditions", null)
                  num_retries      = lookup(retry_policy.value, "num_retries", null)
                  dynamic "per_try_timeout" {
                    for_each = lookup(retry_policy.value, "per_try_timeout", {}) != {} ? [lookup(retry_policy.value, "per_try_timeout")] : []
                    content {
                      seconds = lookup(per_try_timeout.value, "seconds", null)
                      nanos   = lookup(per_try_timeout.value, "nanos", null)
                    }
                  }
                }
              }
              dynamic "timeout" {
                for_each = lookup(route_action.value, "timeout", {}) != {} ? [lookup(route_action.value, "timeout")] : []
                content {
                  seconds = lookup(timeout.value, "seconds", null)
                  nanos   = lookup(timeout.value, "nanos", null)
                }
              }
              dynamic "url_rewrite" {
                for_each = lookup(route_action.value, "url_rewrite", {}) != {} ? [lookup(route_action.value, "url_rewrite")] : []
                content {
                  host_rewrite          = lookup(url_rewrite.value, "host_rewrite", null)
                  path_prefix_rewrite   = lookup(url_rewrite.value, "path_prefix_rewrite", null)
                  path_template_rewrite = lookup(url_rewrite.value, "path_template_rewrite", null)
                }
              }
              dynamic "weighted_backend_services" {
                for_each = lookup(route_action.value, "weighted_backend_services", {}) != {} ? [lookup(route_action.value, "weighted_backend_services")] : []
                content {
                  backend_service = lookup(weighted_backend_services.value, "backend_service", null)
                  weight          = lookup(weighted_backend_services.value, "weight", null)
                  dynamic "header_action" {
                    for_each = lookup(weighted_backend_services.value, "header_action", {}) != {} ? [lookup(weighted_backend_services.value, "header_action")] : []
                    content {
                      request_headers_to_remove  = lookup(header_action.value, "request_headers_to_remove", null)
                      response_headers_to_remove = lookup(header_action.value, "response_headers_to_remove", null)
                      dynamic "request_headers_to_add" {
                        for_each = lookup(header_action.value, "request_headers_to_add", {}) != {} ? [lookup(header_action.value, "request_headers_to_add")] : []
                        content {
                          header_name  = lookup(request_headers_to_add.value, "header_name", null)
                          header_value = lookup(request_headers_to_add.value, "header_value", null)
                          replace      = lookup(request_headers_to_add.value, "replace", null)
                        }
                      }
                      dynamic "response_headers_to_add" {
                        for_each = lookup(header_action.value, "response_headers_to_add", {}) != {} ? [lookup(header_action.value, "response_headers_to_add")] : []
                        content {
                          header_name  = lookup(response_headers_to_add.value, "header_name", null)
                          header_value = lookup(response_headers_to_add.value, "header_value", null)
                          replace      = lookup(response_headers_to_add.value, "replace", null)
                        }
                      }
                    }
                  }
                }
              }
            }
          }
          dynamic "header_action" {
            for_each = lookup(route_rules.value, "header_action", {}) != {} ? [lookup(route_rules.value, "header_action")] : []
            content {
              request_headers_to_remove  = lookup(header_action.value, "request_headers_to_remove", null)
              response_headers_to_remove = lookup(header_action.value, "response_headers_to_remove", null)
              dynamic "request_headers_to_add" {
                for_each = lookup(header_action.value, "request_headers_to_add", {}) != {} ? [lookup(header_action.value, "request_headers_to_add")] : []
                content {
                  header_name  = lookup(request_headers_to_add.value, "header_name", null)
                  header_value = lookup(request_headers_to_add.value, "header_value", null)
                  replace      = lookup(request_headers_to_add.value, "replace", null)
                }
              }
              dynamic "response_headers_to_add" {
                for_each = lookup(header_action.value, "response_headers_to_add", {}) != {} ? [lookup(header_action.value, "response_headers_to_add")] : []
                content {
                  header_name  = lookup(response_headers_to_add.value, "header_name", null)
                  header_value = lookup(response_headers_to_add.value, "header_value", null)
                  replace      = lookup(response_headers_to_add.value, "replace", null)
                }
              }
            }
          }
        }
      }
    }
  }
  dynamic "default_route_action" {
    for_each = var.default_route_action
    content {
      dynamic "weighted_backend_services" {
        for_each = lookup(default_route_action.value, "weighted_backend_services", {}) != {} ? [lookup(default_route_action.value, "weighted_backend_services")] : []
        content {
          backend_service = lookup(weighted_backend_services.value, "backend_service", null)
          weight          = lookup(weighted_backend_services.value, "weight", null)
          dynamic "header_action" {
            for_each = lookup(weighted_backend_services.value, "header_action", {}) != {} ? [lookup(weighted_backend_services.value, "header_action")] : []
            content {
              request_headers_to_remove  = lookup(header_action.value, "request_headers_to_remove", null)
              response_headers_to_remove = lookup(header_action.value, "response_headers_to_remove", null)
              dynamic "request_headers_to_add" {
                for_each = lookup(header_action.value, "request_headers_to_add", {}) != {} ? [lookup(header_action.value, "request_headers_to_add")] : []
                content {
                  header_name  = lookup(request_headers_to_add.value, "header_name", null)
                  header_value = lookup(request_headers_to_add.value, "header_value", null)
                  replace      = lookup(request_headers_to_add.value, "replace", null)
                }
              }
              dynamic "response_headers_to_add" {
                for_each = lookup(header_action.value, "response_headers_to_add", {}) != {} ? [lookup(header_action.value, "response_headers_to_add")] : []
                content {
                  header_name  = lookup(response_headers_to_add.value, "header_name", null)
                  header_value = lookup(response_headers_to_add.value, "header_value", null)
                  replace      = lookup(response_headers_to_add.value, "replace", null)
                }
              }
            }
          }
        }
      }
      dynamic "url_rewrite" {
        for_each = lookup(default_route_action.value, "url_rewrite", {}) != {} ? [lookup(default_route_action.value, "url_rewrite")] : []
        content {
          path_prefix_rewrite = lookup(url_rewrite.value, "path_prefix_rewrite", null)
          host_rewrite        = lookup(url_rewrite.value, "host_rewrite", null)
        }
      }
      dynamic "timeout" {
        for_each = lookup(default_route_action.value, "timeout", {}) != {} ? [lookup(default_route_action.value, "timeout")] : []
        content {
          seconds = lookup(timeout.value, "seconds", null)
          nanos   = lookup(timeout.value, "nanos", null)
        }
      }
      dynamic "retry_policy" {
        for_each = lookup(default_route_action.value, "retry_policy", {}) != {} ? [lookup(default_route_action.value, "retry_policy")] : []
        content {
          retry_conditions = lookup(retry_policy.value, "retry_conditions", null)
          num_retries      = lookup(retry_policy.value, "num_retries", null)
          dynamic "per_try_timeout" {
            for_each = lookup(retry_policy.value, "per_try_timeout", {}) != {} ? [lookup(retry_policy.value, "per_try_timeout")] : []
            content {
              seconds = lookup(per_try_timeout.value, "seconds", null)
              nanos   = lookup(per_try_timeout.value, "nanos", null)
            }
          }
        }
      }
      dynamic "request_mirror_policy" {
        for_each = lookup(default_route_action.value, "request_mirror_policy", {}) != {} ? [lookup(default_route_action.value, "request_mirror_policy")] : []
        content {
          backend_service = lookup(request_mirror_policy.value, "backend_service", null)
        }
      }
      dynamic "cors_policy" {
        for_each = lookup(default_route_action.value, "cors_policy", {}) != {} ? [lookup(default_route_action.value, "cors_policy")] : []
        content {
          allow_credentials    = lookup(cors_policy.value, "allow_credentials", null)
          allow_headers        = lookup(cors_policy.value, "allow_headers", null)
          allow_methods        = lookup(cors_policy.value, "allow_methods", null)
          allow_origins        = lookup(cors_policy.value, "allow_origins", null)
          allow_origin_regexes = lookup(cors_policy.value, "allow_origin_regexes", null)
          disabled             = lookup(cors_policy.value, "disabled", null)
          expose_headers       = lookup(cors_policy.value, "expose_headers", null)
          max_age              = lookup(cors_policy.value, "max_age", null)
        }
      }
      dynamic "fault_injection_policy" {
        for_each = lookup(default_route_action.value, "fault_injection_policy", {}) != {} ? [lookup(default_route_action.value, "fault_injection_policy")] : []
        content {
          dynamic "abort" {
            for_each = lookup(fault_injection_policy.value, "abort", {}) != {} ? [lookup(fault_injection_policy.value, "abort")] : []
            content {
              http_status = lookup(abort.value, "http_status", null)
              percentage  = lookup(abort.value, "percentage", null)
            }
          }
          dynamic "delay" {
            for_each = lookup(fault_injection_policy.value, "delay", {}) != {} ? [lookup(fault_injection_policy.value, "delay")] : []
            content {
              percentage = lookup(delay.value, "percentage", null)
              dynamic "fixed_delay" {
                for_each = lookup(delay.value, "fixed_delay", {}) != {} ? [lookup(delay.value, "fixed_delay")] : []
                content {
                  nanos   = lookup(fixed_delay.value, "nanos", null)
                  seconds = lookup(fixed_delay.value, "seconds", null)
                }
              }
            }
          }
        }
      }
    }
  }
  dynamic "test" {
    for_each = var.test
    content {
      description = lookup(test.value, "description", null)
      host        = lookup(test.value, "host", null)
      path        = lookup(test.value, "path", null)
      service     = lookup(test.value, "service", null)
    }
  }
}

resource "google_compute_region_url_map" "regional_url_map" {
  count           = var.url_map_type == "regional" ? 1 : 0
  project         = var.gcp_project
  region          = var.gcp_region
  name            = var.url_map
  default_service = var.default_service
  description     = var.url_map_description
  depends_on      = [google_compute_backend_service.global_backend, google_compute_region_backend_service.regional_backend]

  dynamic "host_rule" {
    for_each = var.host_rule
    content {
      description  = lookup(host_rule.value, "description", null)
      hosts        = lookup(host_rule.value, "hosts", null)
      path_matcher = lookup(host_rule.value, "path_matcher", null)
    }
  }
  dynamic "path_matcher" {
    for_each = var.path_matcher
    content {
      name            = lookup(path_matcher.value, "name", null)
      default_service = lookup(path_matcher.value, "default_service", null)
      description     = lookup(path_matcher.value, "description", null)

      dynamic "default_url_redirect" {
        for_each = lookup(path_matcher.value, "default_url_redirect", {}) != {} ? [lookup(path_matcher.value, "default_url_redirect")] : []
        content {
          host_redirect          = lookup(default_url_redirect.value, "host_redirect", null)
          https_redirect         = lookup(default_url_redirect.value, "https_redirect", null)
          path_redirect          = lookup(default_url_redirect.value, "path_redirect", null)
          prefix_redirect        = lookup(default_url_redirect.value, "prefix_redirect", null)
          redirect_response_code = lookup(default_url_redirect.value, "redirect_response_code", null)
          strip_query            = lookup(default_url_redirect.value, "strip_query", null)
        }
      }

      dynamic "path_rule" {
        for_each = lookup(path_matcher.value, "path_rule", {}) != {} ? [lookup(path_matcher.value, "path_rule")] : []
        content {
          service = lookup(path_rule.value, "service", null)
          paths   = lookup(path_rule.value, "paths", null)
          dynamic "route_action" {
            for_each = lookup(path_rule.value, "route_action", {}) != {} ? [lookup(path_rule.value, "route_action")] : []
            content {
              dynamic "cors_policy" {
                for_each = lookup(route_action.value, "cors_policy", {}) != {} ? [lookup(route_action.value, "cors_policy")] : []
                content {
                  allow_credentials    = lookup(cors_policy.value, "allow_credentials", null)
                  allow_headers        = lookup(cors_policy.value, "allow_headers", null)
                  allow_methods        = lookup(cors_policy.value, "allow_methods", null)
                  allow_origins        = lookup(cors_policy.value, "allow_origins", null)
                  allow_origin_regexes = lookup(cors_policy.value, "allow_origin_regexes", null)
                  disabled             = lookup(cors_policy.value, "disabled", null)
                  expose_headers       = lookup(cors_policy.value, "expose_headers", null)
                  max_age              = lookup(cors_policy.value, "max_age", null)
                }
              }
              dynamic "fault_injection_policy" {
                for_each = lookup(route_action.value, "fault_injection_policy", {}) != {} ? [lookup(route_action.value, "fault_injection_policy")] : []
                content {
                  dynamic "abort" {
                    for_each = lookup(fault_injection_policy.value, "abort", {}) != {} ? [lookup(fault_injection_policy.value, "abort")] : []
                    content {
                      http_status = lookup(abort.value, "http_status", null)
                      percentage  = lookup(abort.value, "percentage", null)
                    }
                  }
                  dynamic "delay" {
                    for_each = lookup(fault_injection_policy.value, "delay", {}) != {} ? [lookup(fault_injection_policy.value, "delay")] : []
                    content {
                      percentage = lookup(delay.value, "percentage", null)
                      dynamic "fixed_delay" {
                        for_each = lookup(delay.value, "fixed_delay", {}) != {} ? [lookup(delay.value, "fixed_delay")] : []
                        content {
                          nanos   = lookup(fixed_delay.value, "nanos", null)
                          seconds = lookup(fixed_delay.value, "seconds", null)
                        }
                      }
                    }
                  }
                }
              }
              dynamic "request_mirror_policy" {
                for_each = lookup(route_action.value, "request_mirror_policy", {}) != {} ? [lookup(route_action.value, "request_mirror_policy")] : []
                content {
                  backend_service = lookup(request_mirror_policy.value, "backend_service", null)
                }
              }
              dynamic "retry_policy" {
                for_each = lookup(route_action.value, "retry_policy", {}) != {} ? [lookup(route_action.value, "retry_policy")] : []
                content {
                  retry_conditions = lookup(retry_policy.value, "retry_conditions", null)
                  num_retries      = lookup(retry_policy.value, "num_retries", null)
                  dynamic "per_try_timeout" {
                    for_each = lookup(retry_policy.value, "per_try_timeout", {}) != {} ? [lookup(retry_policy.value, "per_try_timeout")] : []
                    content {
                      seconds = lookup(per_try_timeout.value, "seconds", null)
                      nanos   = lookup(per_try_timeout.value, "nanos", null)
                    }
                  }
                }
              }
              dynamic "timeout" {
                for_each = lookup(route_action.value, "timeout", {}) != {} ? [lookup(route_action.value, "timeout")] : []
                content {
                  seconds = lookup(timeout.value, "seconds", null)
                  nanos   = lookup(timeout.value, "nanos", null)
                }
              }
              dynamic "url_rewrite" {
                for_each = lookup(route_action.value, "url_rewrite", {}) != {} ? [lookup(route_action.value, "url_rewrite")] : []
                content {
                  host_rewrite        = lookup(url_rewrite.value, "host_rewrite", null)
                  path_prefix_rewrite = lookup(url_rewrite.value, "path_prefix_rewrite", null)
                }
              }
              dynamic "weighted_backend_services" {
                for_each = lookup(route_action.value, "weighted_backend_services", {}) != {} ? [lookup(route_action.value, "weighted_backend_services")] : []
                content {
                  backend_service = lookup(weighted_backend_services.value, "backend_service", null)
                  weight          = lookup(weighted_backend_services.value, "weight", null)
                  dynamic "header_action" {
                    for_each = lookup(weighted_backend_services.value, "header_action", {}) != {} ? [lookup(weighted_backend_services.value, "header_action")] : []
                    content {
                      request_headers_to_remove  = lookup(header_action.value, "request_headers_to_remove", null)
                      response_headers_to_remove = lookup(header_action.value, "response_headers_to_remove", null)

                      dynamic "request_headers_to_add" {
                        for_each = lookup(header_action.value, "request_headers_to_add", {}) != {} ? [lookup(header_action.value, "request_headers_to_add")] : []
                        content {
                          header_name  = lookup(request_headers_to_add.value, "header_name", null)
                          header_value = lookup(request_headers_to_add.value, "header_value", null)
                          replace      = lookup(request_headers_to_add.value, "replace", null)
                        }
                      }
                      dynamic "response_headers_to_add" {
                        for_each = lookup(header_action.value, "response_headers_to_add", {}) != {} ? [lookup(header_action.value, "response_headers_to_add")] : []
                        content {
                          header_name  = lookup(response_headers_to_add.value, "header_name", null)
                          header_value = lookup(response_headers_to_add.value, "header_value", null)
                          replace      = lookup(response_headers_to_add.value, "replace", null)
                        }
                      }
                    }
                  }
                }
              }
            }
          }
          dynamic "url_redirect" {
            for_each = lookup(path_rule.value, "url_redirect", {}) != {} ? [lookup(path_rule.value, "url_redirect")] : []
            content {
              host_redirect          = lookup(url_redirect.value, "host_redirect", null)
              https_redirect         = lookup(url_redirect.value, "https_redirect", null)
              path_redirect          = lookup(url_redirect.value, "path_redirect", null)
              prefix_redirect        = lookup(url_redirect.value, "prefix_redirect", null)
              redirect_response_code = lookup(url_redirect.value, "redirect_response_code", null)
              strip_query            = lookup(url_redirect.value, "strip_query", null)
            }
          }
        }
      }
      dynamic "route_rules" {
        for_each = try(path_matcher.value["route_rules"], {}) != {} ? path_matcher.value["route_rules"] : null
        # for_each = lookup(path_matcher.value, "route_rules", {}) != {} ? [lookup(path_matcher.value, "route_rules")] : []
        content {
          priority = lookup(route_rules.value, "priority", null)
          service  = lookup(route_rules.value, "service", null)
          dynamic "url_redirect" {
            for_each = lookup(route_rules.value, "url_redirect", {}) != {} ? [lookup(route_rules.value, "url_redirect")] : []
            content {
              host_redirect          = lookup(url_redirect.value, "host_redirect", null)
              https_redirect         = lookup(url_redirect.value, "https_redirect", null)
              path_redirect          = lookup(url_redirect.value, "path_redirect", null)
              prefix_redirect        = lookup(url_redirect.value, "prefix_redirect", null)
              redirect_response_code = lookup(url_redirect.value, "redirect_response_code", null)
              strip_query            = lookup(url_redirect.value, "strip_query", null)
            }
          }
          dynamic "match_rules" {
            for_each = lookup(route_rules.value, "match_rules", {}) != {} ? [lookup(route_rules.value, "match_rules")] : []
            content {
              full_path_match     = lookup(match_rules.value, "full_path_match", null)
              ignore_case         = lookup(match_rules.value, "ignore_case", null)
              prefix_match        = lookup(match_rules.value, "prefix_match", null)
              regex_match         = lookup(match_rules.value, "regex_match", null)
              path_template_match = lookup(match_rules.value, "path_template_match", null)
              dynamic "metadata_filters" {
                for_each = lookup(match_rules.value, "metadata_filters", {}) != {} ? [lookup(match_rules.value, "metadata_filters")] : []
                content {
                  filter_match_criteria = lookup(metadata_filters.value, "filter_match_criteria", null)
                  dynamic "filter_labels" {
                    for_each = lookup(metadata_filters.value, "filter_labels", {}) != {} ? [lookup(route_rules.value, "filter_labels")] : []
                    content {
                      name  = lookup(filter_labels.value, "name", null)
                      value = lookup(filter_labels.value, "value", null)
                    }
                  }
                }
              }
              dynamic "query_parameter_matches" {
                for_each = lookup(match_rules.value, "query_parameter_matches", {}) != {} ? [lookup(match_rules.value, "query_parameter_matches")] : []
                content {
                  exact_match   = lookup(query_parameter_matches.value, "exact_match", null)
                  name          = lookup(query_parameter_matches.value, "name", null)
                  present_match = lookup(query_parameter_matches.value, "present_match", null)
                  regex_match   = lookup(query_parameter_matches.value, "regex_match", null)
                }
              }
              dynamic "header_matches" {
                for_each = lookup(match_rules.value, "header_matches", {}) != {} ? [lookup(match_rules.value, "header_matches")] : []
                content {
                  exact_match   = lookup(header_matches.value, "exact_match", null)
                  header_name   = lookup(header_matches.value, "header_name", null)
                  invert_match  = lookup(header_matches.value, "invert_match", null)
                  prefix_match  = lookup(header_matches.value, "prefix_match", null)
                  present_match = lookup(header_matches.value, "present_match", null)
                  regex_match   = lookup(header_matches.value, "regex_match", null)
                  suffix_match  = lookup(header_matches.value, "suffix_match", null)
                  dynamic "range_match" {
                    for_each = lookup(header_matches.value, "range_match", {}) != {} ? [lookup(header_matches.value, "range_match")] : []
                    content {
                      range_end   = lookup(range_match.value, "range_end", null)
                      range_start = lookup(range_match.value, "range_start", null)
                    }
                  }
                }
              }
            }
          }
          dynamic "route_action" {
            for_each = lookup(route_rules.value, "route_action", {}) != {} ? [lookup(route_rules.value, "route_action")] : []
            content {
              dynamic "cors_policy" {
                for_each = lookup(route_action.value, "cors_policy", {}) != {} ? [lookup(route_action.value, "cors_policy")] : []
                content {
                  allow_credentials    = lookup(cors_policy.value, "allow_credentials", null)
                  allow_headers        = lookup(cors_policy.value, "allow_headers", null)
                  allow_methods        = lookup(cors_policy.value, "allow_methods", null)
                  allow_origins        = lookup(cors_policy.value, "allow_origins", null)
                  allow_origin_regexes = lookup(cors_policy.value, "allow_origin_regexes", null)
                  disabled             = lookup(cors_policy.value, "disabled", null)
                  expose_headers       = lookup(cors_policy.value, "expose_headers", null)
                  max_age              = lookup(cors_policy.value, "max_age", null)
                }
              }
              dynamic "fault_injection_policy" {
                for_each = lookup(route_action.value, "fault_injection_policy", {}) != {} ? [lookup(route_action.value, "fault_injection_policy")] : []
                content {
                  dynamic "abort" {
                    for_each = lookup(fault_injection_policy.value, "abort", {}) != {} ? [lookup(fault_injection_policy.value, "abort")] : []
                    content {
                      http_status = lookup(abort.value, "http_status", null)
                      percentage  = lookup(abort.value, "percentage", null)
                    }
                  }
                  dynamic "delay" {
                    for_each = lookup(fault_injection_policy.value, "delay", {}) != {} ? [lookup(fault_injection_policy.value, "delay")] : []
                    content {
                      percentage = lookup(delay.value, "percentage", null)
                      dynamic "fixed_delay" {
                        for_each = lookup(delay.value, "fixed_delay", {}) != {} ? [lookup(delay.value, "fixed_delay")] : []
                        content {
                          nanos   = lookup(fixed_delay.value, "nanos", null)
                          seconds = lookup(fixed_delay.value, "seconds", null)
                        }
                      }
                    }
                  }
                }
              }
              dynamic "request_mirror_policy" {
                for_each = lookup(route_action.value, "request_mirror_policy", {}) != {} ? [lookup(route_action.value, "request_mirror_policy")] : []
                content {
                  backend_service = lookup(request_mirror_policy.value, "backend_service", null)
                }
              }
              dynamic "retry_policy" {
                for_each = lookup(route_action.value, "retry_policy", {}) != {} ? [lookup(route_action.value, "retry_policy")] : []
                content {
                  retry_conditions = lookup(retry_policy.value, "retry_conditions", null)
                  num_retries      = lookup(retry_policy.value, "num_retries", null)
                  dynamic "per_try_timeout" {
                    for_each = lookup(retry_policy.value, "per_try_timeout", {}) != {} ? [lookup(retry_policy.value, "per_try_timeout")] : []
                    content {
                      seconds = lookup(per_try_timeout.value, "seconds", null)
                      nanos   = lookup(per_try_timeout.value, "nanos", null)
                    }
                  }
                }
              }
              dynamic "timeout" {
                for_each = lookup(route_action.value, "timeout", {}) != {} ? [lookup(route_action.value, "timeout")] : []
                content {
                  seconds = lookup(timeout.value, "seconds", null)
                  nanos   = lookup(timeout.value, "nanos", null)
                }
              }
              dynamic "url_rewrite" {
                for_each = lookup(route_action.value, "url_rewrite", {}) != {} ? [lookup(route_action.value, "url_rewrite")] : []
                content {
                  host_rewrite          = lookup(url_rewrite.value, "host_rewrite", null)
                  path_prefix_rewrite   = lookup(url_rewrite.value, "path_prefix_rewrite", null)
                  path_template_rewrite = lookup(url_rewrite.value, "path_template_rewrite", null)
                }
              }
              dynamic "weighted_backend_services" {
                for_each = lookup(route_action.value, "weighted_backend_services", {}) != {} ? [lookup(route_action.value, "weighted_backend_services")] : []
                content {
                  backend_service = lookup(weighted_backend_services.value, "backend_service", null)
                  weight          = lookup(weighted_backend_services.value, "weight", null)
                  dynamic "header_action" {
                    for_each = lookup(weighted_backend_services.value, "header_action", {}) != {} ? [lookup(weighted_backend_services.value, "header_action")] : []
                    content {
                      request_headers_to_remove  = lookup(header_action.value, "request_headers_to_remove", null)
                      response_headers_to_remove = lookup(header_action.value, "response_headers_to_remove", null)
                      dynamic "request_headers_to_add" {
                        for_each = lookup(header_action.value, "request_headers_to_add", {}) != {} ? [lookup(header_action.value, "request_headers_to_add")] : []
                        content {
                          header_name  = lookup(request_headers_to_add.value, "header_name", null)
                          header_value = lookup(request_headers_to_add.value, "header_value", null)
                          replace      = lookup(request_headers_to_add.value, "replace", null)
                        }
                      }
                      dynamic "response_headers_to_add" {
                        for_each = lookup(header_action.value, "response_headers_to_add", {}) != {} ? [lookup(header_action.value, "response_headers_to_add")] : []
                        content {
                          header_name  = lookup(response_headers_to_add.value, "header_name", null)
                          header_value = lookup(response_headers_to_add.value, "header_value", null)
                          replace      = lookup(response_headers_to_add.value, "replace", null)
                        }
                      }
                    }
                  }
                }
              }
            }
          }
          dynamic "header_action" {
            for_each = lookup(route_rules.value, "header_action", {}) != {} ? [lookup(route_rules.value, "header_action")] : []
            content {
              request_headers_to_remove  = lookup(header_action.value, "request_headers_to_remove", null)
              response_headers_to_remove = lookup(header_action.value, "response_headers_to_remove", null)
              dynamic "request_headers_to_add" {
                for_each = lookup(header_action.value, "request_headers_to_add", {}) != {} ? [lookup(header_action.value, "request_headers_to_add")] : []
                content {
                  header_name  = lookup(request_headers_to_add.value, "header_name", null)
                  header_value = lookup(request_headers_to_add.value, "header_value", null)
                  replace      = lookup(request_headers_to_add.value, "replace", null)
                }
              }
              dynamic "response_headers_to_add" {
                for_each = lookup(header_action.value, "response_headers_to_add", {}) != {} ? [lookup(header_action.value, "response_headers_to_add")] : []
                content {
                  header_name  = lookup(response_headers_to_add.value, "header_name", null)
                  header_value = lookup(response_headers_to_add.value, "header_value", null)
                  replace      = lookup(response_headers_to_add.value, "replace", null)
                }
              }
            }
          }
        }
      }
    }
  }
  dynamic "default_url_redirect" {
    for_each = var.default_url_redirect
    content {
      host_redirect          = lookup(default_url_redirect.value, "host_redirect", null)
      https_redirect         = lookup(default_url_redirect.value, "https_redirect", null)
      path_redirect          = lookup(default_url_redirect.value, "path_redirect", null)
      prefix_redirect        = lookup(default_url_redirect.value, "prefix_redirect", null)
      redirect_response_code = lookup(default_url_redirect.value, "redirect_response_code", null)
      strip_query            = lookup(default_url_redirect.value, "strip_query", null)
    }
  }
  dynamic "default_route_action" {
    for_each = var.default_route_action
    content {
      dynamic "weighted_backend_services" {
        for_each = lookup(default_route_action.value, "weighted_backend_services", {}) != {} ? [lookup(default_route_action.value, "weighted_backend_services")] : []
        content {
          backend_service = lookup(weighted_backend_services.value, "backend_service", null)
          weight          = lookup(weighted_backend_services.value, "weight", null)
          dynamic "header_action" {
            for_each = lookup(weighted_backend_services.value, "header_action", {}) != {} ? [lookup(weighted_backend_services.value, "header_action")] : []
            content {
              request_headers_to_remove  = lookup(header_action.value, "request_headers_to_remove", null)
              response_headers_to_remove = lookup(header_action.value, "response_headers_to_remove", null)

              dynamic "request_headers_to_add" {
                for_each = lookup(header_action.value, "request_headers_to_add", {}) != {} ? [lookup(header_action.value, "request_headers_to_add")] : []
                content {
                  header_name  = lookup(request_headers_to_add.value, "header_name", null)
                  header_value = lookup(request_headers_to_add.value, "header_value", null)
                  replace      = lookup(request_headers_to_add.value, "replace", null)
                }
              }
              dynamic "response_headers_to_add" {
                for_each = lookup(header_action.value, "response_headers_to_add", {}) != {} ? [lookup(header_action.value, "response_headers_to_add")] : []
                content {
                  header_name  = lookup(response_headers_to_add.value, "header_name", null)
                  header_value = lookup(response_headers_to_add.value, "header_value", null)
                  replace      = lookup(response_headers_to_add.value, "replace", null)
                }
              }
            }
          }
        }
      }
      dynamic "url_rewrite" {
        for_each = lookup(default_route_action.value, "url_rewrite", {}) != {} ? [lookup(default_route_action.value, "url_rewrite")] : []
        content {
          path_prefix_rewrite = lookup(url_rewrite.value, "path_prefix_rewrite", null)
          host_rewrite        = lookup(url_rewrite.value, "host_rewrite", null)
        }
      }
      dynamic "timeout" {
        for_each = lookup(default_route_action.value, "timeout", {}) != {} ? [lookup(default_route_action.value, "timeout")] : []
        content {
          seconds = lookup(timeout.value, "seconds", null)
          nanos   = lookup(timeout.value, "nanos", null)
        }
      }
      dynamic "retry_policy" {
        for_each = lookup(default_route_action.value, "retry_policy", {}) != {} ? [lookup(default_route_action.value, "retry_policy")] : []
        content {
          retry_conditions = lookup(retry_policy.value, "retry_conditions", null)
          num_retries      = lookup(retry_policy.value, "num_retries", null)
          dynamic "per_try_timeout" {
            for_each = lookup(retry_policy.value, "per_try_timeout", {}) != {} ? [lookup(retry_policy.value, "per_try_timeout")] : []
            content {
              seconds = lookup(per_try_timeout.value, "seconds", null)
              nanos   = lookup(per_try_timeout.value, "nanos", null)
            }
          }
        }
      }
      dynamic "request_mirror_policy" {
        for_each = lookup(default_route_action.value, "request_mirror_policy", {}) != {} ? [lookup(default_route_action.value, "request_mirror_policy")] : []
        content {
          backend_service = lookup(request_mirror_policy.value, "backend_service", null)
        }
      }
      dynamic "cors_policy" {
        for_each = lookup(default_route_action.value, "cors_policy", {}) != {} ? [lookup(default_route_action.value, "cors_policy")] : []
        content {
          allow_origins        = lookup(cors_policy.value, "allow_origins", null)
          allow_origin_regexes = lookup(cors_policy.value, "allow_origin_regexes", null)
          allow_methods        = lookup(cors_policy.value, "allow_methods", null)
          allow_headers        = lookup(cors_policy.value, "allow_headers", null)
          expose_headers       = lookup(cors_policy.value, "expose_headers", null)
          max_age              = lookup(cors_policy.value, "max_age", null)
          allow_credentials    = lookup(cors_policy.value, "allow_credentials", null)
          disabled             = lookup(cors_policy.value, "disabled", null)
        }
      }
      dynamic "fault_injection_policy" {
        for_each = lookup(default_route_action.value, "fault_injection_policy", {}) != {} ? [lookup(default_route_action.value, "fault_injection_policy")] : []
        content {
          dynamic "abort" {
            for_each = lookup(fault_injection_policy.value, "abort", {}) != {} ? [lookup(fault_injection_policy.value, "abort")] : []
            content {
              http_status = lookup(abort.value, "http_status", null)
              percentage  = lookup(abort.value, "percentage", null)
            }
          }
          dynamic "delay" {
            for_each = lookup(fault_injection_policy.value, "delay", {}) != {} ? [lookup(fault_injection_policy.value, "delay")] : []
            content {
              percentage = lookup(delay.value, "percentage", null)
              dynamic "fixed_delay" {
                for_each = lookup(delay.value, "fixed_delay", {}) != {} ? [lookup(delay.value, "fixed_delay")] : []
                content {
                  nanos   = lookup(fixed_delay.value, "nanos", null)
                  seconds = lookup(fixed_delay.value, "seconds", null)
                }
              }
            }
          }
        }
      }
    }
  }
  dynamic "test" {
    for_each = var.test
    content {
      description = lookup(test.value, "description", null)
      host        = lookup(test.value, "host", null)
      path        = lookup(test.value, "path", null)
      service     = lookup(test.value, "service", null)
    }
  }
}


# --------------------------------------------------------------------
# CLOUD LOAD BALANCING - NETWORK SERVICES - BACKENDS - BACKEND SERVICE
# --------------------------------------------------------------------
resource "google_compute_backend_service" "global_backend" {
  count                           = var.backend_type == "global" ? 1 : 0
  project                         = var.gcp_project
  name                            = var.backend_name
  affinity_cookie_ttl_sec         = var.affinity_cookie_ttl_sec
  compression_mode                = var.compression_mode
  connection_draining_timeout_sec = var.connection_draining_timeout_sec
  custom_request_headers          = var.custom_request_headers
  custom_response_headers         = var.custom_response_headers
  description                     = var.backend_description
  enable_cdn                      = var.enable_cdn
  health_checks                   = var.health_checks
  load_balancing_scheme           = var.backend_load_balancing_scheme
  locality_lb_policy              = var.locality_lb_policy
  port_name                       = var.port_name
  protocol                        = var.protocol
  session_affinity                = var.session_affinity
  security_policy                 = var.security_policy
  timeout_sec                     = var.backend_timeout_sec
  depends_on                      = [google_compute_health_check.health_check, google_compute_global_network_endpoint_group.global_neg, google_compute_region_network_endpoint_group.regional_neg]

  dynamic "backend" {
    for_each = var.backend
    content {
      balancing_mode               = lookup(backend.value, "balancing_mode", null)
      capacity_scaler              = lookup(backend.value, "capacity_scaler", null)
      description                  = lookup(backend.value, "description", null)
      group                        = lookup(backend.value, "group", null)
      max_connections              = lookup(backend.value, "max_connections", null)
      max_connections_per_endpoint = lookup(backend.value, "max_connections_per_endpoint", null)
      max_connections_per_instance = lookup(backend.value, "max_connections_per_instance", null)
      max_rate                     = lookup(backend.value, "max_rate", null)
      max_rate_per_endpoint        = lookup(backend.value, "max_rate_per_endpoint", null)
      max_rate_per_instance        = lookup(backend.value, "max_rate_per_instance", null)
      max_utilization              = lookup(backend.value, "max_utilization", null)
    }
  }
  dynamic "circuit_breakers" {
    for_each = var.circuit_breakers
    content {
      max_requests_per_connection = lookup(circuit_breakers.value, "max_requests_per_connection", null)
      max_connections             = lookup(circuit_breakers.value, "max_connections", null)
      max_pending_requests        = lookup(circuit_breakers.value, "max_pending_requests", null)
      max_requests                = lookup(circuit_breakers.value, "max_requests", null)
      max_retries                 = lookup(circuit_breakers.value, "max_retries", null)
    }
  }
  dynamic "consistent_hash" {
    for_each = var.consistent_hash
    content {
      http_header_name  = lookup(consistent_hash.value, "http_header_name", null)
      minimum_ring_size = lookup(consistent_hash.value, "minimum_ring_size", null)
      dynamic "http_cookie" {
        for_each = lookup(consistent_hash.value, "http_cookie", {}) != {} ? [lookup(consistent_hash.value, "http_cookie")] : []
        content {
          name = lookup(http_cookie.value, "name", null)
          path = lookup(http_cookie.value, "path", null)
          dynamic "ttl" {
            for_each = lookup(http_cookie.value, "ttl", {}) != {} ? [lookup(http_cookie.value, "ttl")] : []
            content {
              seconds = lookup(ttl.value, "seconds", null)
              nanos   = lookup(ttl.value, "nanos", null)
            }
          }
        }
      }
    }
  }
  dynamic "cdn_policy" {
    for_each = var.cdn_policy
    content {
      signed_url_cache_max_age_sec = lookup(cdn_policy.value, "signed_url_cache_max_age_sec", null)
      default_ttl                  = lookup(cdn_policy.value, "default_ttl", null)
      max_ttl                      = lookup(cdn_policy.value, "max_ttl", null)
      client_ttl                   = lookup(cdn_policy.value, "client_ttl", null)
      negative_caching             = lookup(cdn_policy.value, "negative_caching", null)
      cache_mode                   = lookup(cdn_policy.value, "cache_mode", null)
      serve_while_stale            = lookup(cdn_policy.value, "serve_while_stale", null)
      dynamic "cache_key_policy" {
        for_each = lookup(cdn_policy.value, "cache_key_policy", {}) != {} ? [lookup(cdn_policy.value, "cache_key_policy")] : []
        content {
          include_host           = lookup(cache_key_policy.value, "include_host", null)
          include_protocol       = lookup(cache_key_policy.value, "include_protocol", null)
          include_query_string   = lookup(cache_key_policy.value, "include_query_string", null)
          query_string_blacklist = lookup(cache_key_policy.value, "query_string_blacklist", null)
          query_string_whitelist = lookup(cache_key_policy.value, "query_string_whitelist", null)
          include_http_headers   = lookup(cache_key_policy.value, "include_http_headers", null)
          include_named_cookies  = lookup(cache_key_policy.value, "include_named_cookies", null)
        }
      }
      dynamic "negative_caching_policy" {
        for_each = lookup(cdn_policy.value, "negative_caching_policy", {}) != {} ? [lookup(cdn_policy.value, "negative_caching_policy")] : []
        content {
          code = lookup(negative_caching_policy.value, "code", null)
          ttl  = lookup(negative_caching_policy.value, "ttl", null)
        }
      }
      # dynamic "bypass_cache_on_request_headers" {
      #     for_each = lookup(cdn_policy.value, "bypass_cache_on_request_headers", {}) != {} ? [lookup(cdn_policy.value, "bypass_cache_on_request_headers")] : []
      #     content {
      #         header_name = lookup(bypass_cache_on_request_headers.value, "header_name")
      #     }
      # }
    }
  }
  dynamic "iap" {
    for_each = var.iap
    content {
      # enabled                     = lookup(iap.value, "enabled", null)
      oauth2_client_id            = lookup(iap.value, "oauth2_client_id", null)
      oauth2_client_secret        = lookup(iap.value, "oauth2_client_secret", null)
      oauth2_client_secret_sha256 = lookup(iap.value, "oauth2_client_secret_sha256", null)
    }
  }
  # dynamic "locality_lb_policies" {
  #     for_each     = var.locality_lb_policies
  #     content {
  #         dynamic "policy" {
  #             for_each = lookup(locality_lb_policies.value, "policy", {}) != {} ? [lookup(locality_lb_policies.value, "policy")] : []
  #             content {
  #                 name   = lookup(policy.value, "name")
  #                 data   = lookup(policy.value, "data")
  #             }
  #         }
  #         dynamic "custom_policy" {
  #             for_each = lookup(locality_lb_policies.value, "custom_policy", {}) != {} ? [lookup(locality_lb_policies.value, "custom_policy")] : []
  #             content {
  #                 name   = lookup(custom_policy.value, "name")
  #             }
  #         }
  #     }
  # }
  dynamic "outlier_detection" {
    for_each = var.outlier_detection
    content {
      consecutive_errors                    = lookup(outlier_detection.value, "consecutive_errors", null)
      consecutive_gateway_failure           = lookup(outlier_detection.value, "consecutive_gateway_failure", null)
      enforcing_consecutive_errors          = lookup(outlier_detection.value, "enforcing_consecutive_errors", null)
      enforcing_consecutive_gateway_failure = lookup(outlier_detection.value, "enforcing_consecutive_gateway_failure", null)
      enforcing_success_rate                = lookup(outlier_detection.value, "enforcing_success_rate", null)
      max_ejection_percent                  = lookup(outlier_detection.value, "max_ejection_percent", null)
      success_rate_minimum_hosts            = lookup(outlier_detection.value, "success_rate_minimum_hosts", null)
      success_rate_request_volume           = lookup(outlier_detection.value, "success_rate_request_volume", null)
      success_rate_stdev_factor             = lookup(outlier_detection.value, "success_rate_stdev_factor", null)
      dynamic "base_ejection_time" {
        for_each = lookup(outlier_detection.value, "base_ejection_time", {}) != {} ? [lookup(outlier_detection.value, "base_ejection_time")] : []
        content {
          seconds = lookup(base_ejection_time.value, "seconds", null)
          nanos   = lookup(base_ejection_time.value, "nanos", null)
        }
      }
      dynamic "interval" {
        for_each = lookup(outlier_detection.value, "interval", {}) != {} ? [lookup(outlier_detection.value, "interval")] : []
        content {
          seconds = lookup(interval.value, "seconds", null)
          nanos   = lookup(interval.value, "nanos", null)
        }
      }
    }
  }
  dynamic "security_settings" {
    for_each = var.security_settings
    content {
      client_tls_policy = lookup(security_settings.value, "client_tls_policy", null)
      subject_alt_names = lookup(security_settings.value, "subject_alt_names", null)
    }
  }
  dynamic "log_config" {
    for_each = var.backend_log_config
    content {
      enable      = lookup(log_config.value, "enable", null)
      sample_rate = lookup(log_config.value, "sample_rate", null)
    }
  }
}

resource "google_compute_region_backend_service" "regional_backend" {
  count                           = var.backend_type == "regional" ? 1 : 0
  project                         = var.gcp_project
  region                          = var.gcp_region
  name                            = var.backend_name
  affinity_cookie_ttl_sec         = var.affinity_cookie_ttl_sec
  connection_draining_timeout_sec = var.connection_draining_timeout_sec
  description                     = var.backend_description
  enable_cdn                      = var.enable_cdn
  health_checks                   = var.health_checks
  load_balancing_scheme           = var.backend_load_balancing_scheme
  locality_lb_policy              = var.locality_lb_policy
  network                         = var.backend_load_balancing_scheme != "INTERNAL_MANAGED" ? var.network : null
  port_name                       = var.port_name
  protocol                        = var.protocol
  session_affinity                = var.session_affinity
  timeout_sec                     = var.backend_timeout_sec
  depends_on                      = [google_compute_health_check.health_check, google_compute_global_network_endpoint_group.global_neg, google_compute_region_network_endpoint_group.regional_neg]

  dynamic "backend" {
    for_each = var.backend
    content {
      balancing_mode               = lookup(backend.value, "balancing_mode", null)
      capacity_scaler              = lookup(backend.value, "capacity_scaler", null)
      description                  = lookup(backend.value, "description", null)
      failover                     = lookup(backend.value, "failover", null)
      group                        = lookup(backend.value, "group", null)
      max_connections_per_endpoint = lookup(backend.value, "max_connections_per_endpoint", null)
      max_connections_per_instance = lookup(backend.value, "max_connections_per_instance", null)
      max_rate                     = lookup(backend.value, "max_rate", null)
      max_rate_per_endpoint        = lookup(backend.value, "max_rate_per_endpoint", null)
      max_rate_per_instance        = lookup(backend.value, "max_rate_per_instance", null)
      max_utilization              = lookup(backend.value, "max_utilization", null)
    }
  }
  dynamic "circuit_breakers" {
    for_each = var.circuit_breakers
    content {
      max_requests_per_connection = lookup(circuit_breakers.value, "max_requests_per_connection", null)
      max_connections             = lookup(circuit_breakers.value, "max_connections", null)
      max_pending_requests        = lookup(circuit_breakers.value, "max_pending_requests", null)
      max_requests                = lookup(circuit_breakers.value, "max_requests", null)
      max_retries                 = lookup(circuit_breakers.value, "max_retries", null)
    }
  }
  dynamic "consistent_hash" {
    for_each = var.consistent_hash
    content {
      http_header_name  = lookup(consistent_hash.value, "http_header_name", null)
      minimum_ring_size = lookup(consistent_hash.value, "minimum_ring_size", null)
      dynamic "http_cookie" {
        for_each = lookup(consistent_hash.value, "http_cookie", {}) != {} ? [lookup(consistent_hash.value, "http_cookie")] : []
        content {
          name = lookup(http_cookie.value, "name", null)
          path = lookup(http_cookie.value, "path", null)
          dynamic "ttl" {
            for_each = lookup(http_cookie.value, "ttl", {}) != {} ? [lookup(http_cookie.value, "ttl")] : []
            content {
              seconds = lookup(ttl.value, "seconds", null)
              nanos   = lookup(ttl.value, "nanos", null)
            }
          }
        }
      }
    }
  }
  dynamic "cdn_policy" {
    for_each = var.cdn_policy
    content {
      signed_url_cache_max_age_sec = lookup(cdn_policy.value, "signed_url_cache_max_age_sec", null)
      default_ttl                  = lookup(cdn_policy.value, "default_ttl", null)
      max_ttl                      = lookup(cdn_policy.value, "max_ttl", null)
      client_ttl                   = lookup(cdn_policy.value, "client_ttl", null)
      negative_caching             = lookup(cdn_policy.value, "negative_caching", null)
      cache_mode                   = lookup(cdn_policy.value, "cache_mode", null)
      serve_while_stale            = lookup(cdn_policy.value, "serve_while_stale", null)
      dynamic "cache_key_policy" {
        for_each = lookup(cdn_policy.value, "cache_key_policy", {}) != {} ? [lookup(cdn_policy.value, "cache_key_policy")] : []
        content {
          include_host           = lookup(cache_key_policy.value, "include_host", null)
          include_protocol       = lookup(cache_key_policy.value, "include_protocol", null)
          include_query_string   = lookup(cache_key_policy.value, "include_query_string", null)
          query_string_blacklist = lookup(cache_key_policy.value, "query_string_blacklist", null)
          query_string_whitelist = lookup(cache_key_policy.value, "query_string_whitelist", null)
          include_named_cookies  = lookup(cache_key_policy.value, "include_named_cookies", null)
        }
      }
      dynamic "negative_caching_policy" {
        for_each = lookup(cdn_policy.value, "negative_caching_policy", {}) != {} ? [lookup(cdn_policy.value, "negative_caching_policy")] : []
        content {
          code = lookup(negative_caching_policy.value, "code", null)
        }
      }
    }
  }
  dynamic "failover_policy" {
    for_each = var.failover_policy
    content {
      disable_connection_drain_on_failover = lookup(failover_policy.value, "disable_connection_drain_on_failover", null)
      drop_traffic_if_unhealthy            = lookup(failover_policy.value, "drop_traffic_if_unhealthy", null)
      failover_ratio                       = lookup(failover_policy.value, "failover_ratio", null)
    }
  }
  dynamic "iap" {
    for_each = var.iap
    content {
      # enabled              = lookup(iap.value, "enabled", null)
      oauth2_client_id     = lookup(iap.value, "oauth2_client_id", null)
      oauth2_client_secret = lookup(iap.value, "oauth2_client_secret", null)
    }
  }
  dynamic "outlier_detection" {
    for_each = var.outlier_detection
    content {
      consecutive_errors           = lookup(outlier_detection.value, "consecutive_errors", null)
      consecutive_gateway_failure  = lookup(outlier_detection.value, "consecutive_gateway_failure", null)
      enforcing_consecutive_errors = lookup(outlier_detection.value, "enforcing_consecutive_errors", null)
      enforcing_success_rate       = lookup(outlier_detection.value, "enforcing_success_rate", null)
      max_ejection_percent         = lookup(outlier_detection.value, "max_ejection_percent", null)
      success_rate_minimum_hosts   = lookup(outlier_detection.value, "success_rate_minimum_hosts", null)
      success_rate_request_volume  = lookup(outlier_detection.value, "success_rate_request_volume", null)
      success_rate_stdev_factor    = lookup(outlier_detection.value, "success_rate_stdev_factor", null)
      dynamic "base_ejection_time" {
        for_each = lookup(outlier_detection.value, "base_ejection_time", {}) != {} ? [lookup(outlier_detection.value, "base_ejection_time")] : []
        content {
          seconds = lookup(base_ejection_time.value, "seconds", null)
          nanos   = lookup(base_ejection_time.value, "nanos", null)
        }
      }
      dynamic "interval" {
        for_each = lookup(outlier_detection.value, "interval", {}) != {} ? [lookup(outlier_detection.value, "interval")] : []
        content {
          seconds = lookup(interval.value, "seconds", null)
          nanos   = lookup(interval.value, "nanos", null)
        }
      }
    }
  }
  dynamic "log_config" {
    for_each = var.backend_log_config
    content {
      enable      = lookup(log_config.value, "enable", null)
      sample_rate = lookup(log_config.value, "sample_rate", null)
    }
  }
}

# --------------------------------------------------------------------
# CLOUD LOAD BALANCING - NETWORK SERVICES - BACKENDS - HEALTH CHECK
# --------------------------------------------------------------------
resource "google_compute_health_check" "health_check" {
  count               = var.health_check != null ? 1 : 0
  project             = var.gcp_project
  name                = var.health_check
  check_interval_sec  = var.check_interval_sec
  description         = var.health_check_description
  healthy_threshold   = var.healthy_threshold
  timeout_sec         = var.health_check_timeout_sec
  unhealthy_threshold = var.unhealthy_threshold

  dynamic "http_health_check" {
    for_each = var.http_health_check
    content {
      host               = lookup(http_health_check.value, "host", null)
      request_path       = lookup(http_health_check.value, "request_path", null)
      response           = lookup(http_health_check.value, "response", null)
      port               = lookup(http_health_check.value, "port", null)
      port_name          = lookup(http_health_check.value, "port_name", null)
      proxy_header       = lookup(http_health_check.value, "proxy_header", null)
      port_specification = lookup(http_health_check.value, "port_specification", null)
    }
  }
  dynamic "https_health_check" {
    for_each = var.https_health_check
    content {
      host               = lookup(https_health_check.value, "host", null)
      request_path       = lookup(https_health_check.value, "request_path", null)
      response           = lookup(https_health_check.value, "response", null)
      port               = lookup(https_health_check.value, "port", null)
      port_name          = lookup(https_health_check.value, "port_name", null)
      proxy_header       = lookup(https_health_check.value, "proxy_header", null)
      port_specification = lookup(https_health_check.value, "port_specification", null)
    }
  }
  dynamic "tcp_health_check" {
    for_each = var.tcp_health_check
    content {
      request            = lookup(tcp_health_check.value, "request", null)
      response           = lookup(tcp_health_check.value, "response", null)
      port               = lookup(tcp_health_check.value, "port", null)
      port_name          = lookup(tcp_health_check.value, "port_name", null)
      proxy_header       = lookup(tcp_health_check.value, "proxy_header", null)
      port_specification = lookup(tcp_health_check.value, "port_specification", null)
    }
  }
  dynamic "ssl_health_check" {
    for_each = var.ssl_health_check
    content {
      request            = lookup(ssl_health_check.value, "request", null)
      response           = lookup(ssl_health_check.value, "response", null)
      port               = lookup(ssl_health_check.value, "port", null)
      port_name          = lookup(ssl_health_check.value, "port_name", null)
      proxy_header       = lookup(ssl_health_check.value, "proxy_header", null)
      port_specification = lookup(ssl_health_check.value, "port_specification", null)
    }
  }
  dynamic "http2_health_check" {
    for_each = var.http2_health_check
    content {
      host               = lookup(http2_health_check.value, "host", null)
      request_path       = lookup(http2_health_check.value, "request_path", null)
      response           = lookup(http2_health_check.value, "response", null)
      port               = lookup(http2_health_check.value, "port", null)
      port_name          = lookup(http2_health_check.value, "port_name", null)
      proxy_header       = lookup(http2_health_check.value, "proxy_header", null)
      port_specification = lookup(http2_health_check.value, "port_specification", null)
    }
  }
  dynamic "grpc_health_check" {
    for_each = var.grpc_health_check
    content {
      port               = lookup(grpc_health_check.value, "port", null)
      port_name          = lookup(grpc_health_check.value, "port_name", null)
      port_specification = lookup(grpc_health_check.value, "port_specification", null)
      grpc_service_name  = lookup(grpc_health_check.value, "grpc_service_name", null)
    }
  }
  dynamic "log_config" {
    for_each = var.health_check_log_config
    content {
      enable = lookup(log_config.value, "enable", null)
    }
  }
}

# --------------------------------------------------------------------
# CLOUD LOAD BALANCING - NETWORK SERVICES - BACKENDS - NETWORK ENDPOINT GROUP
# --------------------------------------------------------------------
resource "google_compute_global_network_endpoint_group" "global_neg" {
  count                 = var.neg_type == "global" ? 1 : 0
  project               = var.gcp_project
  name                  = var.neg
  network_endpoint_type = var.network_endpoint_type
  default_port          = var.default_port
  description           = var.neg_description
}

resource "google_compute_region_network_endpoint_group" "regional_neg" {
  count                 = var.neg_type == "regional" ? 1 : 0
  project               = var.gcp_project
  region                = var.gcp_region
  name                  = var.neg
  description           = var.neg_description
  network               = var.network_endpoint_type != "SERVERLESS" ? var.network : null
  network_endpoint_type = var.network_endpoint_type
  psc_target_service    = var.psc_target_service
  subnetwork            = var.network_endpoint_type != "SERVERLESS" ? var.subnetwork : null

  dynamic "app_engine" {
    for_each = var.app_engine
    content {
      service  = lookup(app_engine.value, "service", null)
      version  = lookup(app_engine.value, "version", null)
      url_mask = lookup(app_engine.value, "url_mask", null)
    }
  }
  dynamic "cloud_function" {
    for_each = var.cloud_function
    content {
      function = lookup(cloud_function.value, "function", null)
      url_mask = lookup(cloud_function.value, "url_mask", null)
    }
  }
  dynamic "cloud_run" {
    for_each = var.cloud_run
    content {
      service  = lookup(cloud_run.value, "service", null)
      tag      = lookup(cloud_run.value, "tag", null)
      url_mask = lookup(cloud_run.value, "url_mask", null)
    }
  }
}

# --------------------------------------------------------------------
# COMPUTE ENGINE - INSTANCE GROUP
# --------------------------------------------------------------------
resource "google_compute_instance_group" "instance_group" {
  count       = var.instance_group != null ? 1 : 0
  project     = var.gcp_project
  zone        = var.gcp_zone
  name        = var.instance_group
  description = var.instance_group_description
  instances   = var.instances
  network     = var.network

  dynamic "named_port" {
    for_each = var.named_port
    content {
      name = lookup(named_port.value, "name", null)
      port = lookup(named_port.value, "port", null)
    }
  }
}
