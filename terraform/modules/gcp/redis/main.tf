# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# REDIS - INSTANCE
# --------------------------------------------------------------------
resource "google_redis_instance" "redis" {
  project                 = var.gcp_project
  region                  = var.gcp_region
  name                    = var.name
  memory_size_gb          = var.memory_size_gb
  alternative_location_id = var.alternative_location_id
  auth_enabled            = var.auth_enabled
  authorized_network      = var.authorized_network
  connect_mode            = var.connect_mode
  customer_managed_key    = var.customer_managed_key
  display_name            = var.display_name
  labels                  = var.labels
  location_id             = var.location_id
  read_replicas_mode      = var.read_replicas_mode
  redis_configs           = var.redis_configs
  redis_version           = var.redis_version
  replica_count           = var.replica_count
  reserved_ip_range       = var.reserved_ip_range
  secondary_ip_range      = var.secondary_ip_range
  tier                    = var.tier
  transit_encryption_mode = var.transit_encryption_mode

  dynamic "maintenance_policy" {
    for_each = var.maintenance_policy
    content {
      create_time = lookup(maintenance_policy.value, "create_time", null)
      update_time = lookup(maintenance_policy.value, "update_time", null)
      description = lookup(maintenance_policy.value, "description", null)
      dynamic "weekly_maintenance_window" {
        for_each = lookup(maintenance_policy.value, "weekly_maintenance_window", {}) != {} ? [lookup(maintenance_policy.value, "weekly_maintenance_window")] : []
        content {
          day      = lookup(weekly_maintenance_window.value, "day", null)
          duration = lookup(weekly_maintenance_window.value, "duration", null)
          dynamic "start_time" {
            for_each = lookup(weekly_maintenance_window.value, "start_time", {}) != {} ? [lookup(weekly_maintenance_window.value, "start_time")] : []
            content {
              hours   = lookup(start_time.value, "hours", null)
              minutes = lookup(start_time.value, "minutes", null)
              seconds = lookup(start_time.value, "seconds", null)
              nanos   = lookup(start_time.value, "nanos", null)
            }
          }
        }
      }
    }
  }
  dynamic "persistence_config" {
    for_each = var.persistence_config
    content {
      persistence_mode        = lookup(persistence_config.value, "persistence_mode", null)
      rdb_snapshot_period     = lookup(persistence_config.value, "rdb_snapshot_period", null)
      rdb_next_snapshot_time  = lookup(persistence_config.value, "rdb_next_snapshot_time", null)
      rdb_snapshot_start_time = lookup(persistence_config.value, "rdb_snapshot_start_time", null)
    }
  }
}
