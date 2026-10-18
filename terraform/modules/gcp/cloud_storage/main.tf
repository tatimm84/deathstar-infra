# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# CLOUD STORAGE - BUCKET
# --------------------------------------------------------------------
resource "google_storage_bucket" "bucket" {
  count                       = var.bucket_create ? 1 : 0
  project                     = var.gcp_project
  location                    = var.gcp_region
  name                        = var.bucket
  default_event_based_hold    = var.default_event_based_hold
  enable_object_retention     = var.enable_object_retention
  force_destroy               = var.force_destroy
  labels                      = var.labels
  public_access_prevention    = var.public_access_prevention
  requester_pays              = var.requester_pays
  rpo                         = var.rpo
  storage_class               = var.storage_class_bucket
  uniform_bucket_level_access = var.uniform_bucket_level_access

  dynamic "autoclass" {
    for_each = var.autoclass
    content {
      enabled                = lookup(autoclass.value, "enabled", null)
      terminal_storage_class = lookup(autoclass.value, "terminal_storage_class", null)
    }
  }
  dynamic "cors" {
    for_each = var.cors
    content {
      max_age_seconds = lookup(cors.value, "max_age_seconds", null)
      method          = lookup(cors.value, "method", null)
      origin          = lookup(cors.value, "origin", null)
      response_header = lookup(cors.value, "response_header", null)
    }
  }
  dynamic "custom_placement_config" {
    for_each = var.custom_placement_config
    content {
      data_locations = lookup(custom_placement_config.value, "data_locations", null)
    }
  }
  dynamic "encryption" {
    for_each = var.encryption
    content {
      default_kms_key_name = lookup(encryption.value, "default_kms_key_name", null)
    }
  }
  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_rule
    content {
      dynamic "action" {
        for_each = lookup(lifecycle_rule.value, "action", {}) != {} ? [lookup(lifecycle_rule.value, "action")] : []
        content {
          type          = lookup(action.value, "type", null)
          storage_class = lookup(action.value, "storage_class", null)
        }
      }
      dynamic "condition" {
        for_each = lookup(lifecycle_rule.value, "condition", {}) != {} ? [lookup(lifecycle_rule.value, "condition")] : []
        content {
          age                        = lookup(condition.value, "age", null)
          created_before             = lookup(condition.value, "created_before", null)
          custom_time_before         = lookup(condition.value, "custom_time_before", null)
          days_since_custom_time     = lookup(condition.value, "days_since_custom_time", null)
          days_since_noncurrent_time = lookup(condition.value, "days_since_noncurrent_time", null)
          matches_prefix             = lookup(condition.value, "matches_prefix", null)
          matches_storage_class      = lookup(condition.value, "matches_storage_class", null)
          matches_suffix             = lookup(condition.value, "matches_suffix", null)
          # no_age                     = lookup(condition.value, "no_age", null)
          num_newer_versions     = lookup(condition.value, "num_newer_versions", null)
          noncurrent_time_before = lookup(condition.value, "noncurrent_time_before", null)
          with_state             = lookup(condition.value, "with_state", null)
        }
      }
    }
  }
  dynamic "logging" {
    for_each = var.logging
    content {
      log_bucket        = lookup(logging.value, "log_bucket", null)
      log_object_prefix = lookup(logging.value, "log_object_prefix", null)
    }
  }
  dynamic "retention_policy" {
    for_each = var.retention_policy
    content {
      is_locked        = lookup(retention_policy.value, "is_locked", null)
      retention_period = lookup(retention_policy.value, "retention_period", null)
    }
  }
  dynamic "soft_delete_policy" {
    for_each = var.soft_delete_policy
    content {
      effective_time             = lookup(soft_delete_policy.value, "effective_time", null)
      retention_duration_seconds = lookup(soft_delete_policy.value, "retention_duration_seconds", null)
    }
  }
  dynamic "versioning" {
    for_each = var.versioning
    content {
      enabled = lookup(versioning.value, "enabled", null)
    }
  }
  dynamic "website" {
    for_each = var.website
    content {
      main_page_suffix = lookup(website.value, "main_page_suffix", null)
      not_found_page   = lookup(website.value, "not_found_page", null)
    }
  }
}

# --------------------------------------------------------------------
# CLOUD STORAGE - OBJECT
# --------------------------------------------------------------------
resource "google_storage_bucket_object" "object" {
  count               = var.object_create ? 1 : 0
  bucket              = var.bucket
  name                = var.name
  content             = var.content
  source              = var.object_source
  metadata            = var.metadata
  cache_control       = var.cache_control
  content_disposition = var.content_disposition
  content_encoding    = var.content_encoding
  content_language    = var.content_language
  content_type        = var.content_type
  detect_md5hash      = var.detect_md5hash
  event_based_hold    = var.event_based_hold
  kms_key_name        = var.kms_key_name
  storage_class       = var.object_storage_class
  temporary_hold      = var.temporary_hold
  depends_on          = [google_storage_bucket.bucket]

  dynamic "customer_encryption" {
    for_each = var.customer_encryption
    content {
      encryption_algorithm = lookup(customer_encryption.value, "encryption_algorithm", null)
      encryption_key       = lookup(customer_encryption.value, "encryption_key", null)
    }
  }
  dynamic "retention" {
    for_each = var.retention
    content {
      mode              = lookup(retention.value, "mode", null)
      retain_until_time = lookup(retention.value, "retain_until_time", null)
    }
  }
}

# --------------------------------------------------------------------
# CLOUD STORAGE - Access Control List (ACLs)
# --------------------------------------------------------------------
resource "google_storage_bucket_access_control" "acl_role" {
  count  = var.acl_role != null ? 1 : 0
  bucket = google_storage_bucket.bucket[0].name
  role   = var.acl_role
  entity = var.acl_entity
}
