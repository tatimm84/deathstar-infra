# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# CLOUD FUNCTIONS - GENERATE .ZIP FILE
# --------------------------------------------------------------------
locals {
  src_files = {
    for file in fileset(var.source_dir, var.file_replace_regex) :
    file => {
      source  = file
      content = templatefile("${var.source_dir}/${file}", var.template_vars)
    }
  }

  other_files = {
    for file in fileset(var.source_dir, "**") :
    file => {
      source = file
    }
    if !contains(keys(local.src_files), file)
  }
}

resource "local_file" "file_src_replace" {
  for_each = local.src_files

  content  = each.value.content
  filename = "generated/${var.name}/${each.value.source}"
}

resource "local_file" "file_src_copy" {
  for_each = local.other_files

  content_base64 = filebase64("${var.source_dir}/${each.value.source}")
  filename       = "generated/${var.name}/${each.value.source}"
}

data "archive_file" "source" {
  type        = "zip"
  source_dir  = "generated/${var.name}"
  output_path = "generated/${var.name}.zip"

  depends_on = [
    local_file.file_src_replace,
    local_file.file_src_copy
  ]
}

# --------------------------------------------------------------------
# CLOUD FUNCTIONS - STORE .ZIP FILE
# --------------------------------------------------------------------
module "object_zip" {
  source        = "../cloud_storage"
  gcp_project   = var.gcp_project
  bucket_create = false
  object_create = true
  bucket        = var.bucket
  name          = "${var.object_prefix}${data.archive_file.source.output_md5}.zip"
  object_source = data.archive_file.source.output_path
  content_type  = "application/zip"
  depends_on    = [data.archive_file.source]
}

# --------------------------------------------------------------------
# CLOUD FUNCTIONS GENERATION 1 - CREATE FUNCTION
# --------------------------------------------------------------------
resource "google_cloudfunctions_function" "function" {
  count                         = var.generation == 1 ? 1 : 0
  project                       = var.gcp_project
  region                        = var.gcp_region
  name                          = var.name
  runtime                       = var.runtime
  available_memory_mb           = var.available_memory_mb
  build_worker_pool             = var.build_worker_pool
  description                   = var.description
  docker_registry               = var.docker_registry
  docker_repository             = var.docker_repository
  entry_point                   = var.entry_point
  environment_variables         = var.environment_variables
  https_trigger_security_level  = var.https_trigger_security_level
  ingress_settings              = var.ingress_settings
  kms_key_name                  = var.kms_key_name
  labels                        = var.labels
  max_instances                 = var.max_instances
  min_instances                 = var.min_instances
  service_account_email         = var.service_account_email
  source_archive_bucket         = var.bucket
  source_archive_object         = module.object_zip.object_name
  timeout                       = var.timeout
  trigger_http                  = var.trigger_http
  vpc_connector                 = var.vpc_connector
  vpc_connector_egress_settings = var.vpc_connector_egress_settings
  depends_on                    = [module.object_zip]

  dynamic "event_trigger" {
    for_each = var.event_trigger
    content {
      event_type = lookup(event_trigger.value, "event_type", null)
      resource   = lookup(event_trigger.value, "resource", null)
      dynamic "failure_policy" {
        for_each = lookup(event_trigger.value, "failure_policy", {}) != {} ? [lookup(event_trigger.value, "failure_policy")] : []
        content {
          retry = lookup(failure_policy.value, "retry", null)
        }
      }
    }
  }
  dynamic "secret_environment_variables" {
    for_each = var.secret_environment_variables
    content {
      key        = lookup(secret_environment_variables.value, "key", null)
      project_id = lookup(secret_environment_variables.value, "project_id", null)
      secret     = lookup(secret_environment_variables.value, "secret", null)
      version    = lookup(secret_environment_variables.value, "version", null)
    }
  }
  dynamic "secret_volumes" {
    for_each = var.secret_volumes
    content {
      mount_path = lookup(secret_volumes.value, "mount_path", null)
      project_id = lookup(secret_volumes.value, "project_id", null)
      secret     = lookup(secret_volumes.value, "secret", null)
      dynamic "versions" {
        for_each = lookup(secret_volumes.value, "versions", {}) != {} ? [lookup(secret_volumes.value, "versions")] : []
        content {
          path    = lookup(versions.value, "path", null)
          version = lookup(versions.value, "version", null)
        }
      }
    }
  }
  dynamic "source_repository" {
    for_each = var.source_repository
    content {
      url = lookup(source_repository.value, "url", null)
    }
  }
}

# --------------------------------------------------------------------
# CLOUD FUNCTIONS GENERATION 2 - CREATE FUNCTION
# --------------------------------------------------------------------
resource "google_cloudfunctions2_function" "function" {
  count        = var.generation == 2 ? 1 : 0
  project      = var.gcp_project
  location     = var.gcp_region
  name         = var.name
  description  = var.description
  labels       = var.labels
  kms_key_name = var.kms_key_name
  depends_on   = [module.object_zip]

  dynamic "build_config" {
    for_each = var.build_config
    content {
      # automatic_update_policy = lookup(build_config.value, "automatic_update_policy", null)
      build                 = lookup(build_config.value, "build", null)
      docker_repository     = lookup(build_config.value, "docker_repository", null)
      entry_point           = lookup(build_config.value, "entry_point", null)
      environment_variables = lookup(build_config.value, "environment_variables", null)
      runtime               = lookup(build_config.value, "runtime", null)
      service_account       = lookup(build_config.value, "service_account", null)
      worker_pool           = lookup(build_config.value, "worker_pool", null)

      # dynamic on_deploy_update_policy {
      #     for_each            = lookup(build_config.value, "on_deploy_update_policy", {}) != {} ? [lookup(build_config.value, "on_deploy_update_policy")] : []
      #     content {
      #         runtime_version = lookup(on_deploy_update_policy.value, "runtime_version", null)
      #     }
      # }
      dynamic "source" {
        for_each = lookup(build_config.value, "source", {}) != {} ? [lookup(build_config.value, "source")] : []
        content {
          dynamic "storage_source" {
            for_each = lookup(source.value, "storage_source", {}) != {} ? [lookup(source.value, "storage_source")] : []
            content {
              bucket     = lookup(storage_source.value, "bucket", var.bucket)
              generation = lookup(storage_source.value, "generation", null)
              object     = lookup(storage_source.value, "object", module.object_zip.object_name)
            }
          }
          dynamic "repo_source" {
            for_each = lookup(source.value, "repo_source", {}) != {} ? [lookup(source.value, "repo_source")] : []
            content {
              branch_name  = lookup(repo_source.value, "branch_name", null)
              commit_sha   = lookup(repo_source.value, "commit_sha", null)
              dir          = lookup(repo_source.value, "dir", null)
              invert_regex = lookup(repo_source.value, "invert_regex", null)
              project_id   = lookup(repo_source.value, "project_id", null)
              repo_name    = lookup(repo_source.value, "repo_name", null)
              tag_name     = lookup(repo_source.value, "tag_name", null)
            }
          }
        }
      }
    }
  }
  dynamic "event_trigger" {
    for_each = var.event_trigger
    content {
      event_type            = lookup(event_trigger.value, "event_type", null)
      pubsub_topic          = lookup(event_trigger.value, "pubsub_topic", null)
      retry_policy          = lookup(event_trigger.value, "retry_policy", null)
      service_account_email = lookup(event_trigger.value, "service_account_email", null)
      trigger               = lookup(event_trigger.value, "trigger", null)
      trigger_region        = lookup(event_trigger.value, "trigger_region", null)
      dynamic "event_filters" {
        for_each = lookup(event_trigger.value, "event_filters", {}) != {} ? [lookup(event_trigger.value, "event_filters")] : []
        content {
          attribute = lookup(event_filters.value, "attribute", null)
          operator  = lookup(event_filters.value, "operator", null)
          value     = lookup(event_filters.value, "value", null)
        }
      }
    }
  }
  dynamic "service_config" {
    for_each = var.service_config
    content {
      all_traffic_on_latest_revision   = lookup(service_config.value, "all_traffic_on_latest_revision", null)
      available_cpu                    = lookup(service_config.value, "available_cpu", null)
      available_memory                 = lookup(service_config.value, "available_memory", null)
      environment_variables            = lookup(service_config.value, "environment_variables", null)
      gcf_uri                          = lookup(service_config.value, "gcf_uri", null)
      ingress_settings                 = lookup(service_config.value, "ingress_settings", null)
      max_instance_count               = lookup(service_config.value, "max_instance_count", null)
      max_instance_request_concurrency = lookup(service_config.value, "max_instance_request_concurrency", null)
      min_instance_count               = lookup(service_config.value, "min_instance_count", null)
      service                          = lookup(service_config.value, "service", null)
      service_account_email            = lookup(service_config.value, "service_account_email", null)
      timeout_seconds                  = lookup(service_config.value, "timeout_seconds", null)
      uri                              = lookup(service_config.value, "uri", null)
      vpc_connector                    = lookup(service_config.value, "vpc_connector", null)
      vpc_connector_egress_settings    = lookup(service_config.value, "vpc_connector_egress_settings", null)

      dynamic "secret_environment_variables" {
        for_each = lookup(service_config.value, "secret_environment_variables", {}) != {} ? [lookup(service_config.value, "secret_environment_variables")] : []
        content {
          key        = lookup(secret_environment_variables.value, "key", null)
          project_id = lookup(secret_environment_variables.value, "project_id", null)
          secret     = lookup(secret_environment_variables.value, "secret", null)
          version    = lookup(secret_environment_variables.value, "version", null)
        }
      }
      dynamic "secret_volumes" {
        for_each = lookup(service_config.value, "secret_volumes", {}) != {} ? [lookup(service_config.value, "secret_volumes")] : []
        content {
          mount_path = lookup(secret_volumes.value, "mount_path", null)
          project_id = lookup(secret_volumes.value, "project_id", null)
          secret     = lookup(secret_volumes.value, "secret", null)
          dynamic "versions" {
            for_each = lookup(secret_volumes.value, "versions", {}) != {} ? [lookup(secret_volumes.value, "versions")] : []
            content {
              path    = lookup(versions.value, "path", null)
              version = lookup(versions.value, "version", null)
            }
          }
        }
      }
    }
  }
}

# --------------------------------------------------------------------
# CLOUD FUNCTIONS - IAM
# --------------------------------------------------------------------
resource "google_cloudfunctions_function_iam_member" "fn_invoker" {
  count          = var.iam_member != null ? 1 : 0
  project        = var.gcp_project
  region         = var.gcp_region
  cloud_function = length(google_cloudfunctions_function.function) > 0 ? google_cloudfunctions_function.function[0].name : google_cloudfunctions2_function.function[0].name
  role           = "roles/cloudfunctions.invoker"
  member         = var.iam_member
  depends_on     = [google_cloudfunctions_function.function, google_cloudfunctions2_function.function]
}
