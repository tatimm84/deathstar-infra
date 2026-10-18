# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# SSL SECURITY - CERTIFICATE MANAGER - SSL CERTIFICATE
# --------------------------------------------------------------------
resource "google_compute_ssl_certificate" "ssl_certificate" {
  count       = (var.ssl_certificate != null) && (var.ssl_certificate_type == "global") ? 1 : 0
  project     = var.gcp_project
  certificate = var.certificate
  private_key = var.private_key
  name        = var.ssl_certificate
  description = var.ssl_certificate_description
  name_prefix = var.name_prefix

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_region_ssl_certificate" "ssl_certificate_regional" {
  count       = (var.ssl_certificate != null) && (var.ssl_certificate_type == "regional") ? 1 : 0
  project     = var.gcp_project
  certificate = var.certificate
  private_key = var.private_key
  name        = var.ssl_certificate
  description = var.ssl_certificate_description
  name_prefix = var.name_prefix

  lifecycle {
    create_before_destroy = true
  }
}

# --------------------------------------------------------------------
# SSL SECURITY - NETWORK SERVICES - SSL POLICY
# --------------------------------------------------------------------
resource "google_compute_ssl_policy" "ssl_policy" {
  count           = (var.ssl_policy != null) && (var.ssl_policy_type == "global") ? 1 : 0
  project         = var.gcp_project
  name            = var.ssl_policy
  profile         = var.profile
  min_tls_version = var.min_tls_version
  custom_features = var.custom_features
}

resource "google_compute_region_ssl_policy" "ssl_policy_regional" {
  count           = (var.ssl_policy != null) && (var.ssl_policy_type == "regional") ? 1 : 0
  project         = var.gcp_project
  region          = var.gcp_region
  name            = var.ssl_policy
  profile         = var.profile
  min_tls_version = var.min_tls_version
  custom_features = var.custom_features
}

# --------------------------------------------------------------------
# SSL SECURITY - NETWORK SECURITY - CLOUD ARMOR POLICY
# --------------------------------------------------------------------
resource "google_compute_security_policy" "armor" {
  count       = var.armor != null ? 1 : 0
  project     = var.gcp_project
  name        = var.armor
  description = var.armor_description
  type        = var.type

  dynamic "advanced_options_config" {
    for_each = var.advanced_options_config
    content {
      json_parsing            = lookup(advanced_options_config.value, "json_parsing", null)
      log_level               = lookup(advanced_options_config.value, "log_level", null)
      user_ip_request_headers = lookup(advanced_options_config.value, "user_ip_request_headers", null)
      dynamic "json_custom_config" {
        for_each = lookup(advanced_options_config.value, "json_custom_config", {}) != {} ? [lookup(advanced_options_config.value, "json_custom_config")] : []
        content {
          content_types = lookup(json_custom_config.value, "content_types", null)
        }
      }
    }
  }
  dynamic "adaptive_protection_config" {
    for_each = var.adaptive_protection_config
    content {
      dynamic "layer_7_ddos_defense_config" {
        for_each = lookup(adaptive_protection_config.value, "layer_7_ddos_defense_config", {}) != {} ? [lookup(adaptive_protection_config.value, "layer_7_ddos_defense_config")] : []
        content {
          enable          = lookup(layer_7_ddos_defense_config.value, "enable", null)
          rule_visibility = lookup(layer_7_ddos_defense_config.value, "rule_visibility", null)
        }
      }
    }
  }
  dynamic "recaptcha_options_config" {
    for_each = var.recaptcha_options_config
    content {
      redirect_site_key = lookup(recaptcha_options_config.value, "redirect_site_key", null)
    }
  }
  dynamic "rule" {
    for_each = var.rule
    content {
      action      = lookup(rule.value, "action", null)
      priority    = lookup(rule.value, "priority", null)
      description = lookup(rule.value, "description", null)
      preview     = lookup(rule.value, "preview", null)
      dynamic "match" {
        for_each = lookup(rule.value, "match", {}) != {} ? [lookup(rule.value, "match")] : []
        content {
          versioned_expr = lookup(match.value, "versioned_expr", null)
          dynamic "config" {
            for_each = lookup(match.value, "config", {}) != {} ? [lookup(match.value, "config")] : []
            content {
              src_ip_ranges = lookup(config.value, "src_ip_ranges", null)
            }
          }
          dynamic "expr" {
            for_each = lookup(match.value, "expr", {}) != {} ? [lookup(match.value, "expr")] : []
            content {
              expression = lookup(expr.value, "expression", null)
            }
          }
        }
      }
      dynamic "header_action" {
        for_each = lookup(rule.value, "header_action", {}) != {} ? [lookup(rule.value, "header_action")] : []
        content {
          dynamic "request_headers_to_adds" {
            for_each = lookup(header_action.value, "request_headers_to_adds", {}) != {} ? [lookup(header_action.value, "request_headers_to_adds")] : []
            content {
              header_name  = lookup(request_headers_to_adds.value, "header_name", null)
              header_value = lookup(request_headers_to_adds.value, "header_value", null)
            }
          }
        }
      }
      dynamic "rate_limit_options" {
        for_each = lookup(rule.value, "rate_limit_options", {}) != {} ? [lookup(rule.value, "rate_limit_options")] : []
        content {
          conform_action      = lookup(rate_limit_options.value, "conform_action", null)
          exceed_action       = lookup(rate_limit_options.value, "exceed_action", null)
          ban_duration_sec    = lookup(rate_limit_options.value, "ban_duration_sec", null)
          enforce_on_key      = lookup(rate_limit_options.value, "enforce_on_key", null)
          enforce_on_key_name = lookup(rate_limit_options.value, "enforce_on_key_name", null)
          dynamic "ban_threshold" {
            for_each = lookup(rate_limit_options.value, "ban_threshold", {}) != {} ? [lookup(rate_limit_options.value, "ban_threshold")] : []
            content {
              count        = lookup(ban_threshold.value, "count", null)
              interval_sec = lookup(ban_threshold.value, "interval_sec", null)
            }
          }
          dynamic "rate_limit_threshold" {
            for_each = lookup(rate_limit_options.value, "rate_limit_threshold", {}) != {} ? [lookup(rate_limit_options.value, "rate_limit_threshold")] : []
            content {
              count        = lookup(rate_limit_threshold.value, "count", null)
              interval_sec = lookup(rate_limit_threshold.value, "interval_sec", null)
            }
          }
        }
      }
      dynamic "redirect_options" {
        for_each = lookup(rule.value, "redirect_options", {}) != {} ? [lookup(rule.value, "redirect_options")] : []
        content {
          type   = lookup(redirect_options.value, "type", null)
          target = lookup(redirect_options.value, "target", null)
        }
      }
    }
  }
}
