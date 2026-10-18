# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# SECRET MANAGER - SECRET
# --------------------------------------------------------------------
resource "google_secret_manager_secret" "secret" {
  count           = var.secret_create ? 1 : 0
  project         = var.gcp_project
  secret_id       = var.secret_id
  annotations     = var.annotations
  expire_time     = var.expire_time
  labels          = var.labels
  ttl             = var.ttl
  version_aliases = var.version_aliases

  dynamic "replication" {
    for_each = var.replication
    content {
      dynamic "auto" {
        for_each = lookup(replication.value, "auto", {}) != {} ? [lookup(replication.value, "auto")] : lookup(replication.value, "user_managed", {}) != {} ? [] : [{}]
        content {
          dynamic "customer_managed_encryption" {
            for_each = lookup(auto.value, "customer_managed_encryption", {}) != {} ? [lookup(auto.value, "customer_managed_encryption")] : []
            content {
              kms_key_name = lookup(customer_managed_encryption.value, "kms_key_name", null)
            }
          }
        }
      }
      dynamic "user_managed" {
        for_each = lookup(replication.value, "user_managed", {}) != {} ? [lookup(replication.value, "user_managed")] : []
        content {
          dynamic "replicas" {
            for_each = lookup(user_managed.value, "replicas", {}) != {} ? [lookup(user_managed.value, "replicas")] : []
            content {
              location = lookup(replicas.value, "location", null)
              dynamic "customer_managed_encryption" {
                for_each = lookup(replicas.value, "customer_managed_encryption", {}) != {} ? [lookup(replicas.value, "customer_managed_encryption")] : []
                content {
                  kms_key_name = lookup(customer_managed_encryption.value, "kms_key_name", null)
                }
              }
            }
          }
        }
      }
    }

  }
  dynamic "rotation" {
    for_each = var.rotation
    content {
      next_rotation_time = lookup(rotation.value, "next_rotation_time", null)
      rotation_period    = lookup(rotation.value, "rotation_period", null)
    }
  }
  dynamic "topics" {
    for_each = var.topics
    content {
      name = lookup(topics.value, "field", null)
    }
  }
}

# --------------------------------------------------------------------
# SECRET MANAGER - VERSION
# --------------------------------------------------------------------
resource "google_secret_manager_secret_version" "version" {
  count                 = var.secret_data != null ? 1 : 0
  secret                = var.secret_path
  secret_data           = var.secret_data
  enabled               = var.enabled
  deletion_policy       = var.deletion_policy
  is_secret_data_base64 = var.is_secret_data_base64
  depends_on            = [google_secret_manager_secret.secret]
}

# --------------------------------------------------------------------
# SECRET MANAGER - IAM MEMBER
# --------------------------------------------------------------------
resource "google_secret_manager_secret_iam_member" "member" {
  for_each   = var.iam_members
  project    = var.gcp_project
  secret_id  = var.secret_id
  role       = var.iam_member_role
  member     = each.value
  depends_on = [google_secret_manager_secret.secret]
}
