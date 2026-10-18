# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# CLOUD IDENTITY - GROUP
# --------------------------------------------------------------------
resource "google_cloud_identity_group" "id_group" {
  count                = var.parent != null ? 1 : 0
  parent               = var.parent
  display_name         = var.display_name
  description          = var.description
  initial_group_config = var.initial_group_config
  labels               = var.labels

  dynamic "group_key" {
    for_each = var.group_key
    content {
      id        = lookup(group_key.value, "id", null)
      namespace = lookup(group_key.value, "namespace", null)
    }
  }
}

# --------------------------------------------------------------------
# CLOUD IDENTITY - GROUP MEMBERSHIP
# --------------------------------------------------------------------
resource "google_cloud_identity_group_membership" "id_group_membership" {
  count      = var.group != null ? 1 : 0
  group      = var.group
  depends_on = [google_cloud_identity_group.id_group]

  dynamic "preferred_member_key" {
    for_each = var.preferred_member_key
    content {
      id        = lookup(preferred_member_key.value, "id", null)
      namespace = lookup(preferred_member_key.value, "namespace", null)
    }
  }
  dynamic "roles" {
    for_each = var.roles
    content {
      name = lookup(roles.value, "name", null)
      dynamic "expiry_detail" {
        for_each = lookup(roles.value, "expiry_detail", {}) != {} ? [lookup(roles.value, "expiry_detail")] : []
        content {
          expire_time = lookup(expiry_detail.value, "expire_time", null)
        }
      }
    }
  }
}
