# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# CLOUD RUN - SERVICE
# --------------------------------------------------------------------
resource "google_cloud_run_v2_service" "service" {
  count            = var.cloud_run_type == "service" ? 1 : 0
  project          = var.gcp_project
  location         = var.gcp_region
  name             = var.name
  annotations      = var.annotations
  client           = var.client
  client_version   = var.client_version
  custom_audiences = var.custom_audiences
  description      = var.description
  ingress          = var.ingress
  labels           = var.labels
  launch_stage     = var.launch_stage

  dynamic "binary_authorization" {
    for_each = var.binary_authorization
    content {
      breakglass_justification = lookup(binary_authorization.value, "breakglass_justification", null)
      use_default              = lookup(binary_authorization.value, "use_default", null)
    }
  }
  dynamic "traffic" {
    for_each = var.traffic
    content {
      type     = lookup(traffic.value, "type", null)
      revision = lookup(traffic.value, "revision", null)
      percent  = lookup(traffic.value, "percent", null)
      tag      = lookup(traffic.value, "tag", null)
    }
  }

  dynamic "template" {
    for_each = var.template
    content {
      annotations                      = lookup(template.value, "annotations", null)
      encryption_key                   = lookup(template.value, "encryption_key", null)
      execution_environment            = lookup(template.value, "execution_environment", null)
      labels                           = lookup(template.value, "labels", null)
      max_instance_request_concurrency = lookup(template.value, "max_instance_request_concurrency", null)
      revision                         = lookup(template.value, "revision", null)
      service_account                  = lookup(template.value, "service_account", null)
      session_affinity                 = lookup(template.value, "session_affinity", null)
      timeout                          = lookup(template.value, "timeout", null)

      dynamic "scaling" {
        for_each = lookup(template.value, "scaling", {}) != {} ? [lookup(template.value, "scaling")] : []
        content {
          min_instance_count = lookup(scaling.value, "min_instance_count", null)
          max_instance_count = lookup(scaling.value, "max_instance_count", null)
        }
      }
      dynamic "volumes" {
        for_each = lookup(template.value, "volumes", {}) != {} ? [lookup(template.value, "volumes")] : []
        content {
          name = lookup(volumes.value, "name", null)
          dynamic "secret" {
            for_each = lookup(volumes.value, "secret", {}) != {} ? [lookup(volumes.value, "secret")] : []
            content {
              secret       = lookup(secret.value, "secret", null)
              default_mode = lookup(secret.value, "default_mode", null)
              dynamic "items" {
                for_each = lookup(secret.value, "items", {}) != {} ? [lookup(secret.value, "items")] : []
                content {
                  path    = lookup(items.value, "path", null)
                  version = lookup(items.value, "version", null)
                  mode    = lookup(items.value, "mode", null)
                }
              }
            }
          }
          dynamic "cloud_sql_instance" {
            for_each = lookup(volumes.value, "cloud_sql_instance", {}) != {} ? [lookup(volumes.value, "cloud_sql_instance")] : []
            content {
              instances = lookup(cloud_sql_instance.value, "instances", null)
            }
          }
          dynamic "gcs" {
            for_each = lookup(volumes.value, "gcs", {}) != {} ? [lookup(volumes.value, "gcs")] : []
            content {
              bucket    = lookup(gcs.value, "bucket", null)
              read_only = lookup(gcs.value, "read_only", null)
            }
          }
          dynamic "nfs" {
            for_each = lookup(volumes.value, "nfs", {}) != {} ? [lookup(volumes.value, "nfs")] : []
            content {
              server    = lookup(nfs.value, "server", null)
              path      = lookup(nfs.value, "path", null)
              read_only = lookup(nfs.value, "read_only", null)
            }
          }
        }
      }
      dynamic "vpc_access" {
        for_each = lookup(template.value, "vpc_access", {}) != {} ? [lookup(template.value, "vpc_access")] : []
        content {
          connector = lookup(vpc_access.value, "connector", null)
          egress    = lookup(vpc_access.value, "egress", null)
          dynamic "network_interfaces" {
            for_each = lookup(vpc_access.value, "network_interfaces", {}) != {} ? [lookup(vpc_access.value, "network_interfaces")] : []
            content {
              network    = lookup(network_interfaces.value, "network", null)
              subnetwork = lookup(network_interfaces.value, "subnetwork", null)
              tags       = lookup(network_interfaces.value, "tags", null)
            }
          }
        }
      }
      dynamic "containers" {
        for_each = lookup(template.value, "containers", {}) != {} ? [lookup(template.value, "containers")] : []
        content {
          image       = lookup(containers.value, "image")
          args        = lookup(containers.value, "args", null)
          command     = lookup(containers.value, "command", null)
          depends_on  = lookup(containers.value, "depends_on", null)
          name        = lookup(containers.value, "name", null)
          working_dir = lookup(containers.value, "working_dir", null)

          dynamic "env" {
            for_each = { for idx, entry in lookup(containers.value, "env", []) : "${idx}" => entry }
            content {
              name  = lookup(env.value, "name", null)
              value = lookup(env.value, "value", null)
              dynamic "value_source" {
                for_each = lookup(env.value, "value_source", {}) != {} ? [lookup(env.value, "value_source")] : []
                content {
                  dynamic "secret_key_ref" {
                    for_each = lookup(value_source.value, "secret_key_ref", {}) != {} ? [lookup(value_source.value, "secret_key_ref")] : []
                    content {
                      secret  = lookup(secret_key_ref.value, "secret", null)
                      version = lookup(secret_key_ref.value, "version", null)
                    }
                  }
                }
              }
            }
          }
          dynamic "resources" {
            for_each = lookup(containers.value, "resources", {}) != {} ? [lookup(containers.value, "resources")] : []
            content {
              limits            = lookup(resources.value, "limits", {}) != {} ? lookup(resources.value, "limits", {}) : null
              cpu_idle          = lookup(resources.value, "cpu_idle", null)
              startup_cpu_boost = lookup(resources.value, "startup_cpu_boost", null)
            }
          }
          dynamic "ports" {
            for_each = lookup(containers.value, "ports", {}) != {} ? [lookup(containers.value, "ports")] : []
            content {
              name           = lookup(ports.value, "name", null)
              container_port = lookup(ports.value, "container_port", null)
            }
          }
          dynamic "volume_mounts" {
            for_each = lookup(containers.value, "volume_mounts", {}) != {} ? [lookup(containers.value, "volume_mounts")] : []
            content {
              name       = lookup(volume_mounts.value, "name", null)
              mount_path = lookup(volume_mounts.value, "mount_path", null)
            }
          }
          dynamic "liveness_probe" {
            for_each = lookup(containers.value, "liveness_probe", {}) != {} ? [lookup(containers.value, "liveness_probe")] : []
            content {
              initial_delay_seconds = lookup(liveness_probe.value, "initial_delay_seconds", null)
              timeout_seconds       = lookup(liveness_probe.value, "timeout_seconds", null)
              period_seconds        = lookup(liveness_probe.value, "period_seconds", null)
              failure_threshold     = lookup(liveness_probe.value, "failure_threshold", null)
              dynamic "http_get" {
                for_each = lookup(liveness_probe.value, "http_get", {}) != {} ? [lookup(liveness_probe.value, "http_get")] : []
                content {
                  path = lookup(http_get.value, "path", null)
                  port = lookup(http_get.value, "port", null)
                  dynamic "http_headers" {
                    for_each = lookup(http_get.value, "http_get", {}) != {} ? [lookup(http_get.value, "http_get")] : []
                    content {
                      name  = lookup(http_headers.value, "name", null)
                      value = lookup(http_headers.value, "value", null)
                    }
                  }
                }
              }
              dynamic "grpc" {
                for_each = lookup(liveness_probe.value, "grpc", {}) != {} ? [lookup(liveness_probe.value, "grpc")] : []
                content {
                  port    = lookup(grpc.value, "port", null)
                  service = lookup(grpc.value, "service", null)
                }
              }
              dynamic "tcp_socket" {
                for_each = lookup(liveness_probe.value, "tcp_socket", {}) != {} ? [lookup(liveness_probe.value, "tcp_socket")] : []
                content {
                  port = lookup(tcp_socket.value, "port", null)
                }
              }
            }
          }
          dynamic "startup_probe" {
            for_each = lookup(containers.value, "startup_probe", {}) != {} ? [lookup(containers.value, "startup_probe")] : []
            content {
              initial_delay_seconds = lookup(startup_probe.value, "initial_delay_seconds", null)
              failure_threshold     = lookup(startup_probe.value, "failure_threshold", null)
              period_seconds        = lookup(startup_probe.value, "period_seconds", null)
              timeout_seconds       = lookup(startup_probe.value, "timeout_seconds", null)
              dynamic "http_get" {
                for_each = lookup(startup_probe.value, "http_get", {}) != {} ? [lookup(startup_probe.value, "http_get")] : []
                content {
                  path = lookup(http_get.value, "path", null)
                  port = lookup(http_get.value, "port", null)
                  dynamic "http_headers" {
                    for_each = lookup(http_get.value, "http_headers", {}) != {} ? [lookup(http_get.value, "http_headers")] : []
                    content {
                      name  = lookup(http_headers.value, "name", null)
                      value = lookup(http_headers.value, "value", null)
                    }
                  }
                }
              }
              dynamic "tcp_socket" {
                for_each = lookup(startup_probe.value, "tcp_socket", {}) != {} ? [lookup(startup_probe.value, "tcp_socket")] : []
                content {
                  port = lookup(tcp_socket.value, "port", null)
                }
              }
              dynamic "grpc" {
                for_each = lookup(startup_probe.value, "grpc", {}) != {} ? [lookup(startup_probe.value, "grpc")] : []
                content {
                  port    = lookup(grpc.value, "port", null)
                  service = lookup(grpc.value, "service", null)
                }
              }
            }
          }
        }
      }
    }
  }
}

# --------------------------------------------------------------------
# CLOUD RUN - SERVICE IAM
# --------------------------------------------------------------------
resource "google_cloud_run_service_iam_member" "iam_member" {
  count      = var.iam_type == "member" ? 1 : 0
  project    = var.gcp_project
  location   = var.gcp_region
  service    = google_cloud_run_v2_service.service[0].name
  role       = "roles/run.invoker"
  member     = var.iam_member
  depends_on = [google_cloud_run_v2_service.service]

  dynamic "condition" {
    for_each = var.iam_condition
    content {
      title       = lookup(condition.value, "title")
      description = lookup(condition.value, "description", null)
      expression  = lookup(condition.value, "expression")
    }
  }
}

resource "google_cloud_run_service_iam_binding" "iam_binding" {
  count      = var.iam_type == "binding" ? 1 : 0
  project    = var.gcp_project
  location   = var.gcp_region
  service    = google_cloud_run_v2_service.service[0].name
  role       = "roles/run.invoker"
  members    = var.iam_members
  depends_on = [google_cloud_run_v2_service.service]

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
    role    = "roles/run.invoker"
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
resource "google_cloud_run_service_iam_policy" "iam_policy" {
  count       = var.iam_type == "policy" ? 1 : 0
  project     = var.gcp_project
  location    = var.gcp_region
  service     = google_cloud_run_v2_service.service[0].name
  policy_data = data.google_iam_policy.iam_data_policy[0].policy_data
  depends_on  = [google_cloud_run_v2_service.service]
}

# --------------------------------------------------------------------
# CLOUD RUN - JOB
# --------------------------------------------------------------------
resource "google_cloud_run_v2_job" "job" {
  count          = var.cloud_run_type == "job" ? 1 : 0
  project        = var.gcp_project
  location       = var.gcp_region
  name           = var.name
  annotations    = var.annotations
  labels         = var.labels
  client         = var.client
  client_version = var.client_version

  dynamic "binary_authorization" {
    for_each = var.binary_authorization
    content {
      breakglass_justification = lookup(binary_authorization.value, "breakglass_justification", null)
      use_default              = lookup(binary_authorization.value, "use_default", null)
    }
  }
  dynamic "template" {
    for_each = var.template
    content {
      annotations = lookup(template.value, "annotations", null)
      labels      = lookup(template.value, "labels", null)
      parallelism = lookup(template.value, "parallelism", null)
      task_count  = lookup(template.value, "task_count", null)
      dynamic "template" {
        for_each = lookup(template.value, "template", {}) != {} ? [lookup(template.value, "template")] : []
        content {
          encryption_key        = lookup(template.value, "encryption_key", null)
          execution_environment = lookup(template.value, "execution_environment", null)
          max_retries           = lookup(template.value, "max_retries", null)
          service_account       = lookup(template.value, "service_account", null)
          timeout               = lookup(template.value, "timeout", null)

          dynamic "containers" {
            for_each = lookup(template.value, "containers", {}) != {} ? [lookup(template.value, "containers")] : []
            content {
              image       = lookup(containers.value, "image")
              args        = lookup(containers.value, "args", null)
              command     = lookup(containers.value, "command", null)
              name        = lookup(containers.value, "name", null)
              working_dir = lookup(containers.value, "working_dir", null)

              dynamic "env" {
                for_each = lookup(containers.value, "env", {}) != {} ? lookup(containers.value, "env") : []
                content {
                  name  = lookup(env.value, "name", null)
                  value = lookup(env.value, "value", null)
                  dynamic "value_source" {
                    for_each = lookup(env.value, "value_source", {}) != {} ? [lookup(env.value, "value_source")] : []
                    content {
                      dynamic "secret_key_ref" {
                        for_each = lookup(value_source.value, "secret_key_ref", {}) != {} ? [lookup(value_source.value, "secret_key_ref")] : []
                        content {
                          secret  = lookup(secret_key_ref.value, "secret", null)
                          version = lookup(secret_key_ref.value, "version", null)
                        }
                      }
                    }
                  }
                }
              }
              dynamic "resources" {
                for_each = lookup(containers.value, "resources", {}) != {} ? [lookup(containers.value, "resources")] : []
                content {
                  limits = lookup(resources.value, "limits", {}) != {} ? lookup(resources.value, "limits", {}) : null
                }
              }
              dynamic "ports" {
                for_each = lookup(containers.value, "ports", {}) != {} ? [lookup(containers.value, "ports")] : []
                content {
                  name           = lookup(ports.value, "name", null)
                  container_port = lookup(ports.value, "container_port", null)
                }
              }
              dynamic "volume_mounts" {
                for_each = lookup(containers.value, "volume_mounts", {}) != {} ? [lookup(containers.value, "volume_mounts")] : []
                content {
                  name       = lookup(volume_mounts.value, "name", null)
                  mount_path = lookup(volume_mounts.value, "mount_path", null)
                }
              }
            }
          }
          dynamic "volumes" {
            for_each = lookup(template.value, "volumes", {}) != {} ? [lookup(template.value, "volumes")] : []
            content {
              name = lookup(volumes.value, "name", null)
              dynamic "secret" {
                for_each = lookup(volumes.value, "secret", {}) != {} ? [lookup(volumes.value, "secret")] : []
                content {
                  secret       = lookup(secret.value, "secret", null)
                  default_mode = lookup(secret.value, "default_mode", null)
                  dynamic "items" {
                    for_each = lookup(secret.value, "items", {}) != {} ? [lookup(secret.value, "items")] : []
                    content {
                      path    = lookup(items.value, "path", null)
                      version = lookup(items.value, "version", null)
                      mode    = lookup(items.value, "mode", null)
                    }
                  }
                }
              }
              dynamic "cloud_sql_instance" {
                for_each = lookup(volumes.value, "cloud_sql_instance", {}) != {} ? [lookup(volumes.value, "cloud_sql_instance")] : []
                content {
                  instances = lookup(cloud_sql_instance.value, "instances", null)
                }
              }
            }
          }
          dynamic "vpc_access" {
            for_each = lookup(template.value, "vpc_access", {}) != {} ? [lookup(template.value, "vpc_access")] : []
            content {
              connector = lookup(vpc_access.value, "connector", null)
              egress    = lookup(vpc_access.value, "egress", null)
              dynamic "network_interfaces" {
                for_each = lookup(vpc_access.value, "network_interfaces", {}) != {} ? [lookup(vpc_access.value, "network_interfaces")] : []
                content {
                  network    = lookup(network_interfaces.value, "network", null)
                  subnetwork = lookup(network_interfaces.value, "subnetwork", null)
                  tags       = lookup(network_interfaces.value, "tags", null)
                }
              }
            }
          }
        }
      }
    }
  }
}
