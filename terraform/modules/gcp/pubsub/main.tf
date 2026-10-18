# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# GCP - PUBSUB
# --------------------------------------------------------------------

# --------------------------------------------------------------------
# PUBSUB - TOPIC
# --------------------------------------------------------------------

resource "google_pubsub_topic" "topic" {
  count   = var.topic_create == "true" ? 1 : 0
  project = var.gcp_project
  name    = var.topic_name

  labels = var.labels

  kms_key_name               = var.kms_key_name
  message_retention_duration = var.message_retention_duration
}

# --------------------------------------------------------------------
# PUBSUB - SUBSCRIPTION
# --------------------------------------------------------------------

resource "google_pubsub_subscription" "subscription" {
  count   = var.subscription_create ? 1 : 0
  project = var.gcp_project
  name    = var.subscription_name
  topic   = var.topic_name

  labels = var.labels

  filter = var.filter

  message_retention_duration = var.message_retention_duration
  retain_acked_messages      = var.retain_acked_messages
  ack_deadline_seconds       = var.ack_deadline_seconds
  enable_message_ordering    = var.enable_message_ordering

  dynamic "push_config" {
    for_each = var.push_config
    content {
      push_endpoint = lookup(push_config.value, "push_endpoint", null)
      oidc_token {
        service_account_email = lookup(push_config.value, "service_account_email", null)
        audience              = lookup(push_config.value, "audience", null)
      }

      attributes = lookup(push_config.value, "attributes", null)
    }
  }

  dynamic "bigquery_config" {
    for_each = var.bigquery_config
    content {
      table            = lookup(bigquery_config.value, "table", null)
      use_table_schema = lookup(bigquery_config.value, "use_table_schema", null)
    }
  }

  dynamic "dead_letter_policy" {
    for_each = var.dead_letter_policy
    content {
      dead_letter_topic     = lookup(dead_letter_policy.value, "dead_letter_topic", null)
      max_delivery_attempts = lookup(dead_letter_policy.value, "max_delivery_attempts", null)
    }
  }

  dynamic "retry_policy" {
    for_each = var.retry_policy
    content {
      minimum_backoff = lookup(retry_policy.value, "minimum_backoff", null)
      maximum_backoff = lookup(retry_policy.value, "maximum_backoff", null)
    }
  }

  dynamic "expiration_policy" {
    for_each = var.expiration_policy
    content {
      ttl = lookup(expiration_policy.value, "ttl", null)
    }
  }
}
