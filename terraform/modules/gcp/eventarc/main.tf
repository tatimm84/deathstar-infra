# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# EVENTARC - TRIGGER
# --------------------------------------------------------------------
resource "google_eventarc_trigger" "trigger" {
  project                 = var.gcp_project
  location                = var.gcp_region
  name                    = var.name
  channel                 = var.channel
  event_data_content_type = var.event_data_content_type
  labels                  = var.labels
  service_account         = var.service_account

  dynamic "destination" {
    for_each = var.destination
    content {
      cloud_function = lookup(destination.value, "cloud_function", "") != "" ? lookup(destination.value, "cloud_function") : null
      workflow       = lookup(destination.value, "workflow", "") != "" ? lookup(destination.value, "workflow") : null
      dynamic "cloud_run_service" {
        for_each = lookup(destination.value, "cloud_run_service", {}) != {} ? [lookup(destination.value, "cloud_run_service")] : []
        content {
          service = lookup(cloud_run_service.value, "service", null)
          path    = lookup(cloud_run_service.value, "path", null)
          region  = lookup(cloud_run_service.value, "region", null)
        }
      }
      dynamic "gke" {
        for_each = lookup(destination.value, "gke", {}) != {} ? [lookup(destination.value, "gke")] : []
        content {
          cluster   = lookup(gke.value, "cluster", null)
          location  = lookup(gke.value, "location", null)
          namespace = lookup(gke.value, "namespace", null)
          service   = lookup(gke.value, "service", null)
          path      = lookup(gke.value, "path", null)
        }
      }
      dynamic "http_endpoint" {
        for_each = lookup(destination.value, "http_endpoint", {}) != {} ? [lookup(destination.value, "http_endpoint")] : []
        content {
          uri = lookup(http_endpoint.value, "uri", null)
        }
      }
      dynamic "network_config" {
        for_each = lookup(destination.value, "network_config", {}) != {} ? [lookup(destination.value, "network_config")] : []
        content {
          network_attachment = lookup(network_config.value, "network_attachment", null)
        }
      }
    }
  }
  dynamic "matching_criteria" {
    for_each = var.matching_criteria
    content {
      attribute = lookup(matching_criteria.value, "attribute", null)
      value     = lookup(matching_criteria.value, "value", null)
      operator  = lookup(matching_criteria.value, "operator", null)
    }
  }
  dynamic "transport" {
    for_each = var.transport
    content {
      dynamic "pubsub" {
        for_each = lookup(transport.value, "pubsub", {}) != {} ? [lookup(transport.value, "pubsub")] : []
        content {
          subscription = lookup(pubsub.value, "subscription", null)
          topic        = lookup(pubsub.value, "topic", null)
        }
      }
    }
  }
}
