# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# COMPUTE ENGINE - INSTANCE
# --------------------------------------------------------------------
resource "google_compute_instance" "instance" {
  count                     = var.name != null ? 1 : 0
  project                   = var.gcp_project
  zone                      = var.gcp_zone
  name                      = var.name
  machine_type              = var.machine_type
  allow_stopping_for_update = var.allow_stopping_for_update
  deletion_protection       = var.deletion_protection
  description               = var.description
  desired_status            = var.desired_status
  enable_display            = var.enable_display
  hostname                  = var.hostname
  labels                    = var.labels
  metadata                  = var.metadata
  metadata_startup_script   = var.metadata_startup_script
  min_cpu_platform          = var.min_cpu_platform
  resource_policies         = length(var.instance_schedule_policy) > 0 ? [google_compute_resource_policy.resource_policy[0].self_link] : []
  tags                      = var.tags

  dynamic "boot_disk" {
    for_each = var.boot_disk
    content {
      auto_delete             = lookup(boot_disk.value, "auto_delete", null)
      device_name             = lookup(boot_disk.value, "device_name", null)
      mode                    = lookup(boot_disk.value, "mode", null)
      disk_encryption_key_raw = lookup(boot_disk.value, "disk_encryption_key_raw", null)
      kms_key_self_link       = lookup(boot_disk.value, "kms_key_self_link", null)
      source                  = lookup(boot_disk.value, "source", null)
      dynamic "initialize_params" {
        for_each = lookup(boot_disk.value, "initialize_params", {}) != {} ? [lookup(boot_disk.value, "initialize_params")] : []
        content {
          image  = lookup(initialize_params.value, "image", null)
          size   = lookup(initialize_params.value, "size", null)
          type   = lookup(initialize_params.value, "type", null)
          labels = lookup(initialize_params.value, "labels", {}) != {} ? lookup(initialize_params.value, "labels") : null
        }
      }
    }
  }
  dynamic "scratch_disk" {
    for_each = var.scratch_disk
    content {
      interface = lookup(scratch_disk.value, "interface", null)
    }
  }
  dynamic "attached_disk" {
    for_each = var.attached_disk
    content {
      source                  = lookup(attached_disk.value, "source", null)
      device_name             = lookup(attached_disk.value, "device_name", null)
      mode                    = lookup(attached_disk.value, "mode", null)
      disk_encryption_key_raw = lookup(attached_disk.value, "disk_encryption_key_raw", null)
      kms_key_self_link       = lookup(attached_disk.value, "kms_key_self_link", null)
    }
  }
  dynamic "network_interface" {
    for_each = var.network_interface
    content {
      network            = lookup(network_interface.value, "network", null)
      network_ip         = lookup(network_interface.value, "network_ip", null)
      subnetwork         = lookup(network_interface.value, "subnetwork", null)
      subnetwork_project = lookup(network_interface.value, "subnetwork_project", null)
      nic_type           = lookup(network_interface.value, "nic_type", null)
      stack_type         = lookup(network_interface.value, "stack_type", null)
      queue_count        = lookup(network_interface.value, "queue_count", null)
      dynamic "access_config" {
        for_each = lookup(network_interface.value, "access_config", {}) != {} ? [lookup(network_interface.value, "access_config")] : []
        content {
          nat_ip                 = lookup(access_config.value, "nat_ip", null)
          public_ptr_domain_name = lookup(access_config.value, "public_ptr_domain_name", null)
          network_tier           = lookup(access_config.value, "network_tier", null)
        }
      }
      dynamic "ipv6_access_config" {
        for_each = lookup(network_interface.value, "ipv6_access_config", {}) != {} ? [lookup(network_interface.value, "ipv6_access_config")] : []
        content {
          # name                        = lookup(ipv6_access_config.value, "name", null)
          external_ipv6               = lookup(ipv6_access_config.value, "external_ipv6", null)
          external_ipv6_prefix_length = lookup(ipv6_access_config.value, "external_ipv6_prefix_length", null)
          network_tier                = lookup(ipv6_access_config.value, "network_tier", null)
          public_ptr_domain_name      = lookup(ipv6_access_config.value, "public_ptr_domain_name", null)
        }
      }
      dynamic "alias_ip_range" {
        for_each = lookup(network_interface.value, "alias_ip_range", {}) != {} ? [lookup(network_interface.value, "alias_ip_range")] : []
        content {
          ip_cidr_range         = lookup(alias_ip_range.value, "ip_cidr_range ", null)
          subnetwork_range_name = lookup(alias_ip_range.value, "subnetwork_range_name", null)
        }
      }
    }
  }
  dynamic "service_account" {
    for_each = var.service_account
    content {
      email  = lookup(service_account.value, "email", null)
      scopes = lookup(service_account.value, "scopes")
    }
  }
  dynamic "scheduling" {
    for_each = var.scheduling
    content {
      preemptible         = lookup(scheduling.value, "preemptible", null)
      on_host_maintenance = lookup(scheduling.value, "on_host_maintenance", null)
      automatic_restart   = lookup(scheduling.value, "automatic_restart", null)
      min_node_cpus       = lookup(scheduling.value, "min_node_cpus", null)
      provisioning_model  = lookup(scheduling.value, "provisioning_model", null)
      # instance_termination_action = lookup(scheduling.value, "instance_termination_action", null)
      # dynamic max_run_duration {
      #     for_each    = lookup(scheduling.value, "max_run_duration", {}) != {} ? [lookup(scheduling.value, "max_run_duration")] : []
      #     content {
      #         nanos   = lookup(max_run_duration.value, "nanos", null)
      #         seconds = lookup(max_run_duration.value, "seconds", null)
      #     }
      # }
      dynamic "node_affinities" {
        for_each = lookup(scheduling.value, "node_affinities", {}) != {} ? [lookup(scheduling.value, "node_affinities")] : []
        content {
          key      = lookup(node_affinities.value, "key", null)
          operator = lookup(node_affinities.value, "operator", null)
          values   = lookup(node_affinities.value, "values", null)
        }
      }
    }
  }
  dynamic "guest_accelerator" {
    for_each = var.guest_accelerator
    content {
      type  = lookup(guest_accelerator.value, "type", null)
      count = lookup(guest_accelerator.value, "count", null)
    }
  }
  dynamic "shielded_instance_config" {
    for_each = var.shielded_instance_config
    content {
      enable_secure_boot          = lookup(shielded_instance_config.value, "enable_secure_boot", null)
      enable_vtpm                 = lookup(shielded_instance_config.value, "enable_vtpm", null)
      enable_integrity_monitoring = lookup(shielded_instance_config.value, "enable_integrity_monitoring", null)
    }
  }
  dynamic "confidential_instance_config" {
    for_each = var.confidential_instance_config
    content {
      enable_confidential_compute = lookup(confidential_instance_config.value, "enable_confidential_compute", null)
    }
  }
  dynamic "advanced_machine_features" {
    for_each = var.advanced_machine_features
    content {
      enable_nested_virtualization = lookup(advanced_machine_features.value, "enable_nested_virtualization", null)
      threads_per_core             = lookup(advanced_machine_features.value, "threads_per_core", null)
      visible_core_count           = lookup(advanced_machine_features.value, "visible_core_count", null)
    }
  }
  dynamic "reservation_affinity" {
    for_each = var.reservation_affinity
    content {
      type = lookup(reservation_affinity.value, "type", null)
      dynamic "specific_reservation" {
        for_each = lookup(reservation_affinity.value, "specific_reservation", {}) != {} ? [lookup(reservation_affinity.value, "specific_reservation")] : []
        content {
          key    = lookup(specific_reservation.value, "key", null)
          values = lookup(specific_reservation.value, "values", null)
        }
      }
    }
  }
}

# --------------------------------------------------------------------
# COMPUTE ENGINE - SCHEDULE BACKUP
# --------------------------------------------------------------------
resource "google_compute_resource_policy" "resource_policy" {
  count   = length(var.instance_schedule_policy) > 0 || length(var.snapshot_schedule_policy) > 0 ? 1 : 0
  project = var.gcp_project
  region  = var.gcp_region
  # region      = regex("^(.*)-[a-z]$", var.gcp_zone)[0]
  name        = var.instance_schedule_name
  description = var.schedule_description
  # depends_on  = [ google_compute_instance.instance ]

  dynamic "snapshot_schedule_policy" {
    for_each = var.snapshot_schedule_policy
    content {
      dynamic "retention_policy" {
        for_each = lookup(snapshot_schedule_policy.value, "retention_policy", {}) != {} ? [lookup(snapshot_schedule_policy.value, "retention_policy")] : []
        content {
          max_retention_days    = lookup(retention_policy.value, "max_retention_days", null)
          on_source_disk_delete = lookup(retention_policy.value, "on_source_disk_delete", null)
        }
      }
      dynamic "snapshot_properties" {
        for_each = lookup(snapshot_schedule_policy.value, "snapshot_properties", {}) != {} ? [lookup(snapshot_schedule_policy.value, "snapshot_properties")] : []
        content {
          labels            = lookup(snapshot_properties.value, "labels", null)
          storage_locations = lookup(snapshot_properties.value, "storage_locations", null)
          guest_flush       = lookup(snapshot_properties.value, "guest_flush", null)
          chain_name        = lookup(snapshot_properties.value, "chain_name", null)
        }
      }
      dynamic "schedule" {
        for_each = lookup(snapshot_schedule_policy.value, "schedule", {}) != {} ? [lookup(snapshot_schedule_policy.value, "schedule")] : []
        content {
          dynamic "hourly_schedule" {
            for_each = lookup(schedule.value, "hourly_schedule", {}) != {} ? [lookup(schedule.value, "hourly_schedule")] : []
            content {
              hours_in_cycle = lookup(hourly_schedule.value, "hours_in_cycle", null)
              start_time     = lookup(hourly_schedule.value, "start_time", null)
            }
          }
          dynamic "daily_schedule" {
            for_each = lookup(schedule.value, "daily_schedule", {}) != {} ? [lookup(schedule.value, "daily_schedule")] : []
            content {
              days_in_cycle = lookup(daily_schedule.value, "days_in_cycle", null)
              start_time    = lookup(daily_schedule.value, "start_time", null)
            }
          }
          dynamic "weekly_schedule" {
            for_each = lookup(schedule.value, "weekly_schedule", {}) != {} ? [lookup(schedule.value, "weekly_schedule")] : []
            content {
              dynamic "day_of_weeks" {
                for_each = lookup(weekly_schedule.value, "day_of_weeks", {}) != {} ? [lookup(weekly_schedule.value, "day_of_weeks")] : []
                content {
                  start_time = lookup(day_of_weeks.value, "start_time", null)
                  day        = lookup(day_of_weeks.value, "day", null)
                }
              }
            }
          }
        }
      }
    }
  }
  dynamic "group_placement_policy" {
    for_each = var.group_placement_policy
    content {
      vm_count                  = lookup(group_placement_policy.value, "vm_count", null)
      availability_domain_count = lookup(group_placement_policy.value, "availability_domain_count", null)
      collocation               = lookup(group_placement_policy.value, "collocation", null)
      # max_distance              = lookup(group_placement_policy.value, "max_distance", null)
    }
  }
  dynamic "instance_schedule_policy" {
    for_each = var.instance_schedule_policy
    content {
      time_zone       = lookup(instance_schedule_policy.value, "time_zone", null)
      start_time      = lookup(instance_schedule_policy.value, "start_time", null)
      expiration_time = lookup(instance_schedule_policy.value, "expiration_time", null)
      dynamic "vm_start_schedule" {
        for_each = lookup(instance_schedule_policy.value, "vm_start_schedule", {}) != {} ? [lookup(instance_schedule_policy.value, "vm_start_schedule")] : []
        content {
          schedule = lookup(vm_start_schedule.value, "schedule", null)
        }
      }
      dynamic "vm_stop_schedule" {
        for_each = lookup(instance_schedule_policy.value, "vm_stop_schedule", {}) != {} ? [lookup(instance_schedule_policy.value, "vm_stop_schedule")] : []
        content {
          schedule = lookup(vm_stop_schedule.value, "schedule", null)
        }
      }
    }
  }
  # dynamic disk_consistency_group_policy {
  #     for_each    = var.disk_consistency_group_policy
  #     content {
  #         enabled = lookup(disk_consistency_group_policy.value, "enabled", null)
  #     }
  # }
}
resource "google_compute_disk_resource_policy_attachment" "policy_attachment" {
  count      = var.attach_schedule ? 1 : 0
  project    = var.gcp_project
  zone       = var.gcp_zone
  name       = google_compute_resource_policy.resource_policy[0].name
  disk       = google_compute_instance.instance[0].name
  depends_on = [google_compute_resource_policy.resource_policy]
}

# --------------------------------------------------------------------
# COMPUTE ENGINE - IAP TUNNEL INSTANCE IAM
# --------------------------------------------------------------------
resource "google_iap_tunnel_instance_iam_member" "iam_member" {
  count      = var.iam_type == "member" ? 1 : 0
  project    = var.gcp_project
  zone       = var.gcp_zone
  instance   = google_compute_instance.instance[0].name
  role       = "roles/iap.tunnelResourceAccessor"
  member     = var.iam_member
  depends_on = [google_compute_instance.instance]

  dynamic "condition" {
    for_each = var.iam_condition
    content {
      title       = lookup(condition.value, "title")
      description = lookup(condition.value, "description", null)
      expression  = lookup(condition.value, "expression")
    }
  }
}

resource "google_iap_tunnel_instance_iam_binding" "iam_binding" {
  count      = var.iam_type == "binding" ? 1 : 0
  project    = var.gcp_project
  zone       = var.gcp_zone
  instance   = google_compute_instance.instance[0].name
  role       = "roles/iap.tunnelResourceAccessor"
  members    = var.iam_members
  depends_on = [google_compute_instance.instance]

  dynamic "condition" {
    for_each = var.iam_condition
    content {
      title       = lookup(condition.value, "title")
      description = lookup(condition.value, "description", null)
      expression  = lookup(condition.value, "expression")
    }
  }
}

data "google_iam_policy" "iam_data_policy" {
  count = var.iam_type == "policy" ? 1 : 0
  binding {
    role    = "roles/iap.tunnelResourceAccessor"
    members = var.iam_members
    dynamic "condition" {
      for_each = var.iam_condition
      content {
        title       = lookup(condition.value, "title")
        description = lookup(condition.value, "description", null)
        expression  = lookup(condition.value, "expression")
      }
    }
  }
}
resource "google_iap_tunnel_instance_iam_policy" "iam_policy" {
  count       = var.iam_type == "policy" ? 1 : 0
  project     = var.gcp_project
  zone        = var.gcp_zone
  instance    = google_compute_instance.instance[0].name
  policy_data = data.google_iam_policy.iam_data_policy[0].policy_data
  depends_on  = [google_compute_instance.instance]
}
