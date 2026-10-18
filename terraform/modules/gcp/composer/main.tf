# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# COMPOSER - VERSION 1
# --------------------------------------------------------------------
resource "google_composer_environment" "composer_1" {
  count   = var.composer_version == 1 ? 1 : 0
  project = var.gcp_project
  region  = var.gcp_region
  name    = var.name
  labels  = var.labels

  dynamic "config" {
    for_each = var.config
    content {
      node_count = lookup(config.value, "node_count", null)
      dynamic "database_config" {
        for_each = lookup(config.value, "database_config", {}) != {} ? [lookup(config.value, "database_config")] : []
        content {
          machine_type = lookup(database_config.value, "machine_type", null)
          zone         = lookup(database_config.value, "zone", null)
        }
      }
      dynamic "encryption_config" {
        for_each = lookup(config.value, "encryption_config", {}) != {} ? [lookup(config.value, "encryption_config")] : []
        content {
          kms_key_name = lookup(encryption_config.value, "kms_key_name", null)
        }
      }
      dynamic "master_authorized_networks_config" {
        for_each = lookup(config.value, "master_authorized_networks_config", {}) != {} ? [lookup(config.value, "master_authorized_networks_config")] : []
        content {
          enabled = lookup(master_authorized_networks_config.value, "enabled", null)
          dynamic "cidr_blocks" {
            for_each = lookup(master_authorized_networks_config.value, "cidr_blocks", {}) != {} ? [lookup(master_authorized_networks_config.value, "cidr_blocks")] : []
            content {
              cidr_block   = lookup(cidr_blocks.value, "cidr_block", null)
              display_name = lookup(cidr_blocks.value, "display_name", null)
            }
          }
        }
      }
      dynamic "node_config" {
        for_each = lookup(config.value, "node_config", {}) != {} ? [lookup(config.value, "node_config")] : []
        content {
          disk_size_gb         = lookup(node_config.value, "disk_size_gb", null)
          enable_ip_masq_agent = lookup(node_config.value, "enable_ip_masq_agent", null)
          machine_type         = lookup(node_config.value, "machine_type", null)
          network              = lookup(node_config.value, "network", null)
          oauth_scopes         = lookup(node_config.value, "oauth_scopes", null)
          service_account      = lookup(node_config.value, "service_account", null)
          subnetwork           = lookup(node_config.value, "subnetwork", null)
          tags                 = lookup(node_config.value, "tags", null)
          zone                 = lookup(node_config.value, "zone", null)
          dynamic "ip_allocation_policy" {
            for_each = lookup(node_config.value, "ip_allocation_policy", {}) != {} ? [lookup(node_config.value, "ip_allocation_policy")] : []
            content {
              cluster_ipv4_cidr_block       = lookup(ip_allocation_policy.value, "cluster_ipv4_cidr_block", null)
              cluster_secondary_range_name  = lookup(ip_allocation_policy.value, "cluster_secondary_range_name", null)
              services_ipv4_cidr_block      = lookup(ip_allocation_policy.value, "services_ipv4_cidr_block", null)
              services_secondary_range_name = lookup(ip_allocation_policy.value, "services_secondary_range_name", null)
              use_ip_aliases                = lookup(ip_allocation_policy.value, "use_ip_aliases", null)
            }
          }
        }
      }
      dynamic "private_environment_config" {
        for_each = lookup(config.value, "private_environment_config", {}) != {} ? [lookup(config.value, "private_environment_config")] : []
        content {
          cloud_sql_ipv4_cidr_block        = lookup(private_environment_config.value, "cloud_sql_ipv4_cidr_block", null)
          connection_type                  = lookup(private_environment_config.value, "connection_type", null)
          enable_private_endpoint          = lookup(private_environment_config.value, "enable_private_endpoint", null)
          enable_privately_used_public_ips = lookup(private_environment_config.value, "enable_privately_used_public_ips", null)
          master_ipv4_cidr_block           = lookup(private_environment_config.value, "master_ipv4_cidr_block", null)
          web_server_ipv4_cidr_block       = lookup(private_environment_config.value, "web_server_ipv4_cidr_block", null)
        }
      }
      dynamic "software_config" {
        for_each = lookup(config.value, "software_config", {}) != {} ? [lookup(config.value, "software_config")] : []
        content {
          airflow_config_overrides = lookup(software_config.value, "airflow_config_overrides", null)
          env_variables            = lookup(software_config.value, "env_variables", null)
          image_version            = lookup(software_config.value, "image_version", null)
          pypi_packages            = lookup(software_config.value, "pypi_packages", null)
          python_version           = lookup(software_config.value, "python_version", null)
          scheduler_count          = lookup(software_config.value, "scheduler_count", null)
        }
      }
      dynamic "web_server_config" {
        for_each = lookup(config.value, "web_server_config", {}) != {} ? [lookup(config.value, "web_server_config")] : []
        content {
          machine_type = lookup(web_server_config.value, "machine_type", null)
        }
      }
      dynamic "web_server_network_access_control" {
        for_each = lookup(config.value, "web_server_network_access_control", {}) != {} ? [lookup(config.value, "web_server_network_access_control")] : []
        content {
          dynamic "allowed_ip_range" {
            for_each = lookup(web_server_network_access_control.value, "allowed_ip_range", {}) != {} ? [lookup(web_server_network_access_control.value, "allowed_ip_range")] : []
            content {
              description = lookup(allowed_ip_range.value, "description", null)
              value       = lookup(allowed_ip_range.value, "value", null)
            }
          }
        }
      }
    }
  }
}

# --------------------------------------------------------------------
# COMPOSER - VERSION 2
# --------------------------------------------------------------------
resource "google_composer_environment" "composer_2" {
  count   = var.composer_version == 2 ? 1 : 0
  project = var.gcp_project
  region  = var.gcp_region
  name    = var.name
  labels  = var.labels

  dynamic "config" {
    for_each = var.config
    content {
      environment_size = lookup(config.value, "environment_size", null)
      resilience_mode  = lookup(config.value, "resilience_mode", null)
      dynamic "data_retention_config" {
        for_each = lookup(config.value, "data_retention_config", {}) != {} ? [lookup(config.value, "data_retention_config")] : []
        content {
          dynamic "task_logs_retention_config" {
            for_each = lookup(data_retention_config.value, "task_logs_retention_config", {}) != {} ? [lookup(data_retention_config.value, "task_logs_retention_config")] : []
            content {
              storage_mode = lookup(task_logs_retention_config.value, "storage_mode", null)
            }
          }
        }
      }
      dynamic "encryption_config" {
        for_each = lookup(config.value, "encryption_config", {}) != {} ? [lookup(config.value, "encryption_config")] : []
        content {
          kms_key_name = lookup(encryption_config.value, "kms_key_name", null)
        }
      }
      dynamic "maintenance_window" {
        for_each = lookup(config.value, "maintenance_window", {}) != {} ? [lookup(config.value, "maintenance_window")] : []
        content {
          start_time = lookup(maintenance_window.value, "start_time", null)
          end_time   = lookup(maintenance_window.value, "end_time", null)
          recurrence = lookup(maintenance_window.value, "recurrence", null)
        }
      }
      dynamic "master_authorized_networks_config" {
        for_each = lookup(config.value, "master_authorized_networks_config", {}) != {} ? [lookup(config.value, "master_authorized_networks_config")] : []
        content {
          enabled = lookup(master_authorized_networks_config.value, "enabled", null)
          dynamic "cidr_blocks" {
            for_each = lookup(master_authorized_networks_config.value, "cidr_blocks", {}) != {} ? [lookup(master_authorized_networks_config.value, "cidr_blocks")] : []
            content {
              cidr_block   = lookup(cidr_blocks.value, "cidr_block", null)
              display_name = lookup(cidr_blocks.value, "display_name", null)
            }
          }
        }
      }
      dynamic "node_config" {
        for_each = lookup(config.value, "node_config", {}) != {} ? [lookup(config.value, "node_config")] : []
        content {
          enable_ip_masq_agent = lookup(node_config.value, "enable_ip_masq_agent", null)
          network              = lookup(node_config.value, "network", null)
          service_account      = lookup(node_config.value, "service_account", null)
          subnetwork           = lookup(node_config.value, "subnetwork", null)
          tags                 = lookup(node_config.value, "tags", null)
          dynamic "ip_allocation_policy" {
            for_each = lookup(node_config.value, "ip_allocation_policy", {}) != {} ? [lookup(node_config.value, "ip_allocation_policy")] : []
            content {
              cluster_secondary_range_name  = lookup(ip_allocation_policy.value, "cluster_secondary_range_name", null)
              cluster_ipv4_cidr_block       = lookup(ip_allocation_policy.value, "cluster_ipv4_cidr_block", null)
              services_ipv4_cidr_block      = lookup(ip_allocation_policy.value, "services_ipv4_cidr_block", null)
              services_secondary_range_name = lookup(ip_allocation_policy.value, "services_secondary_range_name", null)
            }
          }
        }
      }
      dynamic "private_environment_config" {
        for_each = lookup(config.value, "private_environment_config", {}) != {} ? [lookup(config.value, "private_environment_config")] : []
        content {
          cloud_composer_connection_subnetwork   = lookup(private_environment_config.value, "cloud_composer_connection_subnetwork", null)
          cloud_composer_network_ipv4_cidr_block = lookup(private_environment_config.value, "cloud_composer_network_ipv4_cidr_block", null)
          cloud_sql_ipv4_cidr_block              = lookup(private_environment_config.value, "cloud_sql_ipv4_cidr_block", null)
          enable_private_endpoint                = lookup(private_environment_config.value, "enable_private_endpoint", null)
          enable_privately_used_public_ips       = lookup(private_environment_config.value, "enable_privately_used_public_ips", null)
          master_ipv4_cidr_block                 = lookup(private_environment_config.value, "master_ipv4_cidr_block", null)
        }
      }
      dynamic "recovery_config" {
        for_each = lookup(config.value, "recovery_config", {}) != {} ? [lookup(config.value, "recovery_config")] : []
        content {
          dynamic "scheduled_snapshots_config" {
            for_each = lookup(recovery_config.value, "scheduled_snapshots_config", {}) != {} ? [lookup(recovery_config.value, "scheduled_snapshots_config")] : []
            content {
              enabled                    = lookup(scheduled_snapshots_config.value, "enabled", null)
              snapshot_location          = lookup(scheduled_snapshots_config.value, "snapshot_location", null)
              snapshot_creation_schedule = lookup(scheduled_snapshots_config.value, "snapshot_creation_schedule", null)
              time_zone                  = lookup(scheduled_snapshots_config.value, "time_zone", null)
            }
          }
        }
      }
      dynamic "software_config" {
        for_each = lookup(config.value, "software_config", {}) != {} ? [lookup(config.value, "software_config")] : []
        content {
          airflow_config_overrides = lookup(software_config.value, "airflow_config_overrides", null)
          env_variables            = lookup(software_config.value, "env_variables", null)
          image_version            = lookup(software_config.value, "image_version", null)
          pypi_packages            = lookup(software_config.value, "pypi_packages", null)
        }
      }
      dynamic "workloads_config" {
        for_each = lookup(config.value, "workloads_config", {}) != {} ? [lookup(config.value, "workloads_config")] : []
        content {
          dynamic "scheduler" {
            for_each = lookup(workloads_config.value, "scheduler", {}) != {} ? [lookup(workloads_config.value, "scheduler")] : []
            content {
              count      = lookup(scheduler.value, "count", null)
              cpu        = lookup(scheduler.value, "cpu", null)
              memory_gb  = lookup(scheduler.value, "memory_gb", null)
              storage_gb = lookup(scheduler.value, "storage_gb", null)
            }
          }
          dynamic "triggerer" {
            for_each = lookup(workloads_config.value, "triggerer", {}) != {} ? [lookup(workloads_config.value, "triggerer")] : []
            content {
              count     = lookup(triggerer.value, "count", null)
              cpu       = lookup(triggerer.value, "cpu", null)
              memory_gb = lookup(triggerer.value, "memory_gb", null)
            }
          }
          dynamic "web_server" {
            for_each = lookup(workloads_config.value, "web_server", {}) != {} ? [lookup(workloads_config.value, "web_server")] : []
            content {
              cpu        = lookup(web_server.value, "cpu", null)
              memory_gb  = lookup(web_server.value, "memory_gb", null)
              storage_gb = lookup(web_server.value, "storage_gb", null)
            }
          }
          dynamic "worker" {
            for_each = lookup(workloads_config.value, "worker", {}) != {} ? [lookup(workloads_config.value, "worker")] : []
            content {
              cpu        = lookup(worker.value, "cpu", null)
              memory_gb  = lookup(worker.value, "memory_gb", null)
              min_count  = lookup(worker.value, "min_count", null)
              max_count  = lookup(worker.value, "max_count", null)
              storage_gb = lookup(worker.value, "storage_gb", null)
            }
          }
        }
      }
    }
  }
  dynamic "storage_config" {
    for_each = var.storage_config
    content {
      bucket = lookup(storage_config.value, "bucket", null)
    }
  }
}

# --------------------------------------------------------------------
# COMPOSER - VERSION 3
# --------------------------------------------------------------------

resource "google_composer_environment" "composer_3" {
  count   = var.composer_version == 3 ? 1 : 0
  project = var.gcp_project
  region  = var.gcp_region
  name    = var.name
  labels  = var.labels

  dynamic "config" {
    for_each = var.config
    content {
      environment_size = lookup(config.value, "environment_size", null)
      resilience_mode  = lookup(config.value, "resilience_mode", null)
      dynamic "data_retention_config" {
        for_each = lookup(config.value, "data_retention_config", {}) != {} ? [lookup(config.value, "data_retention_config")] : []
        content {
          dynamic "task_logs_retention_config" {
            for_each = lookup(data_retention_config.value, "task_logs_retention_config", {}) != {} ? [lookup(data_retention_config.value, "task_logs_retention_config")] : []
            content {
              storage_mode = lookup(task_logs_retention_config.value, "storage_mode", null)
            }
          }
        }
      }
      dynamic "encryption_config" {
        for_each = lookup(config.value, "encryption_config", {}) != {} ? [lookup(config.value, "encryption_config")] : []
        content {
          kms_key_name = lookup(encryption_config.value, "kms_key_name", null)
        }
      }
      dynamic "maintenance_window" {
        for_each = lookup(config.value, "maintenance_window", {}) != {} ? [lookup(config.value, "maintenance_window")] : []
        content {
          start_time = lookup(maintenance_window.value, "start_time", null)
          end_time   = lookup(maintenance_window.value, "end_time", null)
          recurrence = lookup(maintenance_window.value, "recurrence", null)
        }
      }
      dynamic "master_authorized_networks_config" {
        for_each = lookup(config.value, "master_authorized_networks_config", {}) != {} ? [lookup(config.value, "master_authorized_networks_config")] : []
        content {
          enabled = lookup(master_authorized_networks_config.value, "enabled", null)
          dynamic "cidr_blocks" {
            for_each = lookup(master_authorized_networks_config.value, "cidr_blocks", {}) != {} ? [lookup(master_authorized_networks_config.value, "cidr_blocks")] : []
            content {
              cidr_block   = lookup(cidr_blocks.value, "cidr_block", null)
              display_name = lookup(cidr_blocks.value, "display_name", null)
            }
          }
        }
      }
      dynamic "node_config" {
        for_each = lookup(config.value, "node_config", {}) != {} ? [lookup(config.value, "node_config")] : []
        content {
          enable_ip_masq_agent = lookup(node_config.value, "enable_ip_masq_agent", null)
          network              = lookup(node_config.value, "network", null)
          service_account      = lookup(node_config.value, "service_account", null)
          subnetwork           = lookup(node_config.value, "subnetwork", null)
          tags                 = lookup(node_config.value, "tags", null)
          dynamic "ip_allocation_policy" {
            for_each = lookup(node_config.value, "ip_allocation_policy", {}) != {} ? [lookup(node_config.value, "ip_allocation_policy")] : []
            content {
              cluster_secondary_range_name  = lookup(ip_allocation_policy.value, "cluster_secondary_range_name", null)
              cluster_ipv4_cidr_block       = lookup(ip_allocation_policy.value, "cluster_ipv4_cidr_block", null)
              services_ipv4_cidr_block      = lookup(ip_allocation_policy.value, "services_ipv4_cidr_block", null)
              services_secondary_range_name = lookup(ip_allocation_policy.value, "services_secondary_range_name", null)
            }
          }
        }
      }
      dynamic "private_environment_config" {
        for_each = lookup(config.value, "private_environment_config", {}) != {} ? [lookup(config.value, "private_environment_config")] : []
        content {
          cloud_composer_connection_subnetwork   = lookup(private_environment_config.value, "cloud_composer_connection_subnetwork", null)
          cloud_composer_network_ipv4_cidr_block = lookup(private_environment_config.value, "cloud_composer_network_ipv4_cidr_block", null)
          cloud_sql_ipv4_cidr_block              = lookup(private_environment_config.value, "cloud_sql_ipv4_cidr_block", null)
          enable_private_endpoint                = lookup(private_environment_config.value, "enable_private_endpoint", null)
          enable_privately_used_public_ips       = lookup(private_environment_config.value, "enable_privately_used_public_ips", null)
          master_ipv4_cidr_block                 = lookup(private_environment_config.value, "master_ipv4_cidr_block", null)
        }
      }
      dynamic "recovery_config" {
        for_each = lookup(config.value, "recovery_config", {}) != {} ? [lookup(config.value, "recovery_config")] : []
        content {
          dynamic "scheduled_snapshots_config" {
            for_each = lookup(recovery_config.value, "scheduled_snapshots_config", {}) != {} ? [lookup(recovery_config.value, "scheduled_snapshots_config")] : []
            content {
              enabled                    = lookup(scheduled_snapshots_config.value, "enabled", null)
              snapshot_location          = lookup(scheduled_snapshots_config.value, "snapshot_location", null)
              snapshot_creation_schedule = lookup(scheduled_snapshots_config.value, "snapshot_creation_schedule", null)
              time_zone                  = lookup(scheduled_snapshots_config.value, "time_zone", null)
            }
          }
        }
      }
      dynamic "software_config" {
        for_each = lookup(config.value, "software_config", {}) != {} ? [lookup(config.value, "software_config")] : []
        content {
          airflow_config_overrides = lookup(software_config.value, "airflow_config_overrides", null)
          env_variables            = lookup(software_config.value, "env_variables", null)
          image_version            = lookup(software_config.value, "image_version", null)
          pypi_packages            = lookup(software_config.value, "pypi_packages", null)
          # web_server_plugins_mode  = lookup(software_config.value, "web_server_plugins_mode", null)
        }
      }
      dynamic "workloads_config" {
        for_each = lookup(config.value, "workloads_config", {}) != {} ? [lookup(config.value, "workloads_config")] : []
        content {
          dynamic "scheduler" {
            for_each = lookup(workloads_config.value, "scheduler", {}) != {} ? [lookup(workloads_config.value, "scheduler")] : []
            content {
              count      = lookup(scheduler.value, "count", null)
              cpu        = lookup(scheduler.value, "cpu", null)
              memory_gb  = lookup(scheduler.value, "memory_gb", null)
              storage_gb = lookup(scheduler.value, "storage_gb", null)
            }
          }
          dynamic "triggerer" {
            for_each = lookup(workloads_config.value, "triggerer", {}) != {} ? [lookup(workloads_config.value, "triggerer")] : []
            content {
              count     = lookup(triggerer.value, "count", null)
              cpu       = lookup(triggerer.value, "cpu", null)
              memory_gb = lookup(triggerer.value, "memory_gb", null)
            }
          }
          dynamic "web_server" {
            for_each = lookup(workloads_config.value, "web_server", {}) != {} ? [lookup(workloads_config.value, "web_server")] : []
            content {
              cpu        = lookup(web_server.value, "cpu", null)
              memory_gb  = lookup(web_server.value, "memory_gb", null)
              storage_gb = lookup(web_server.value, "storage_gb", null)
            }
          }
          dynamic "worker" {
            for_each = lookup(workloads_config.value, "worker", {}) != {} ? [lookup(workloads_config.value, "worker")] : []
            content {
              cpu        = lookup(worker.value, "cpu", null)
              memory_gb  = lookup(worker.value, "memory_gb", null)
              min_count  = lookup(worker.value, "min_count", null)
              max_count  = lookup(worker.value, "max_count", null)
              storage_gb = lookup(worker.value, "storage_gb", null)
            }
          }
        }
      }
    }
  }
  dynamic "storage_config" {
    for_each = var.storage_config
    content {
      bucket = lookup(storage_config.value, "bucket", null)
    }
  }
}
