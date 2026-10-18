# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# ARTIFACT REGISTRY - REPOSITORY
# --------------------------------------------------------------------
resource "google_artifact_registry_repository" "repo" {
  count                  = var.repository_create ? 1 : 0
  project                = var.gcp_project
  location               = var.gcp_region
  repository_id          = var.repository_id
  format                 = var.format
  cleanup_policy_dry_run = var.cleanup_policy_dry_run
  description            = var.description
  kms_key_name           = var.kms_key_name
  mode                   = var.mode

  dynamic "cleanup_policies" {
    for_each = var.cleanup_policies
    content {
      id     = lookup(cleanup_policies.value, "id", null)
      action = lookup(cleanup_policies.value, "action", null)
      dynamic "condition" {
        for_each = lookup(cleanup_policies.value, "condition", {}) != {} ? [lookup(cleanup_policies.value, "condition")] : []
        content {
          tag_state             = lookup(condition.value, "tag_state", null)
          tag_prefixes          = lookup(condition.value, "tag_prefixes", null)
          version_name_prefixes = lookup(condition.value, "version_name_prefixes", null)
          package_name_prefixes = lookup(condition.value, "package_name_prefixes", null)
          older_than            = lookup(condition.value, "older_than", null)
          newer_than            = lookup(condition.value, "newer_than", null)
        }
      }
      dynamic "most_recent_versions" {
        for_each = lookup(cleanup_policies.value, "most_recent_versions", {}) != {} ? [lookup(cleanup_policies.value, "most_recent_versions")] : []
        content {
          package_name_prefixes = lookup(most_recent_versions.value, "package_name_prefixes", null)
          keep_count            = lookup(most_recent_versions.value, "keep_count", null)
        }
      }
    }
  }
  dynamic "docker_config" {
    for_each = var.docker_config
    content {
      immutable_tags = lookup(docker_config.value, "immutable_tags", null)
    }
  }
  dynamic "maven_config" {
    for_each = var.maven_config
    content {
      allow_snapshot_overwrites = lookup(maven_config.value, "allow_snapshot_overwrites", null)
      version_policy            = lookup(maven_config.value, "version_policy", null)
    }
  }
  dynamic "remote_repository_config" {
    for_each = var.remote_repository_config
    content {
      description = lookup(remote_repository_config.value, "description", null)
      dynamic "apt_repository" {
        for_each = lookup(remote_repository_config.value, "apt_repository", {}) != {} ? [lookup(remote_repository_config.value, "apt_repository")] : []
        content {
          dynamic "public_repository" {
            for_each = lookup(apt_repository.value, "public_repository", {}) != {} ? [lookup(apt_repository.value, "public_repository")] : []
            content {
              repository_base = lookup(public_repository.value, "repository_base", null)
              repository_path = lookup(public_repository.value, "repository_path", null)
            }
          }
        }
      }
      dynamic "docker_repository" {
        for_each = lookup(remote_repository_config.value, "docker_repository", {}) != {} ? [lookup(remote_repository_config.value, "docker_repository")] : []
        content {
          public_repository = lookup(docker_repository.value, "public_repository", null)
        }
      }
      dynamic "maven_repository" {
        for_each = lookup(remote_repository_config.value, "maven_repository", {}) != {} ? [lookup(remote_repository_config.value, "maven_repository")] : []
        content {
          public_repository = lookup(maven_repository.value, "public_repository", null)
        }
      }
      dynamic "npm_repository" {
        for_each = lookup(remote_repository_config.value, "npm_repository", {}) != {} ? [lookup(remote_repository_config.value, "npm_repository")] : []
        content {
          public_repository = lookup(npm_repository.value, "public_repository", null)
        }
      }
      dynamic "python_repository" {
        for_each = lookup(remote_repository_config.value, "python_repository", {}) != {} ? [lookup(remote_repository_config.value, "python_repository")] : []
        content {
          public_repository = lookup(python_repository.value, "public_repository", null)
        }
      }
      dynamic "yum_repository" {
        for_each = lookup(remote_repository_config.value, "python_repository", {}) != {} ? [lookup(remote_repository_config.value, "python_repository")] : []
        content {
          dynamic "public_repository" {
            for_each = lookup(yum_repository.value, "public_repository", {}) != {} ? [lookup(yum_repository.value, "public_repository")] : []
            content {
              repository_base = lookup(public_repository.value, "repository_base", null)
              repository_path = lookup(public_repository.value, "repository_path", null)
            }
          }
        }
      }
      dynamic "upstream_credentials" {
        for_each = lookup(remote_repository_config.value, "upstream_credentials", {}) != {} ? [lookup(remote_repository_config.value, "upstream_credentials")] : []
        content {
          dynamic "username_password_credentials" {
            for_each = lookup(upstream_credentials.value, "username_password_credentials", {}) != {} ? [lookup(upstream_credentials.value, "username_password_credentials")] : []
            content {
              username                = lookup(username_password_credentials.value, "username", null)
              password_secret_version = lookup(username_password_credentials.value, "password_secret_version", null)
            }
          }
        }
      }
    }
  }
  dynamic "virtual_repository_config" {
    for_each = var.virtual_repository_config
    content {
      dynamic "upstream_policies" {
        for_each = lookup(virtual_repository_config.value, "upstream_policies", {}) != {} ? [lookup(virtual_repository_config.value, "upstream_policies")] : []
        content {
          id         = lookup(upstream_policies.value, "id", null)
          repository = lookup(upstream_policies.value, "repository", null)
          priority   = lookup(upstream_policies.value, "priority", null)
        }
      }
    }
  }
}

# --------------------------------------------------------------------
# ARTIFACT REGISTRY - IMAGE - DOCKER_IMAGE
# --------------------------------------------------------------------
locals {
  COMMANDS_ARGS = {
    dockerfile = var.build != null ? "${var.context}/${lookup(var.build, "dockerfile", "Dockerfile")}" : null
    build      = var.build != null ? join(" ", setunion([for i in keys(var.build_args_default) : "--build-arg ${i}=${nonsensitive(lookup(var.build_args_default, i))}"], [for i in keys(lookup(var.build, "build_args", {})) : "--build-arg ${i}=${nonsensitive(lookup(lookup(var.build, "build_args", {}), i))}"])) : null
    tags       = var.image_name != null ? join(" ", formatlist("-t ${var.image_name}:%s", var.tag_treated)) : null
    others     = var.build != null ? join(" ", lookup(var.build, "others_command", [])) : null
    mount = distinct(flatten([for file in var.build != null ? lookup(var.build, "mount", []) : [] : [{
      path   = "${var.context}/${join("/", slice(split("/", file.target), 0, length(split("/", file.target)) - 1))}"
      source = file.source
      target = "${var.context}/${file.target}"
      }]
    ]))
  }
}

# Trigger
resource "terraform_data" "trigger" {
  count      = var.image_name != null ? 1 : 0
  input      = join("-", [var.triggers.dir_sha1, var.sha1_json])
  depends_on = [google_artifact_registry_repository.repo]
}

# Docker Login
resource "null_resource" "docker_login" {
  count = var.image_name != null ? 1 : 0
  provisioner "local-exec" {
    command = join("\n", [
      for region in var.login_regions :
      "docker login -u oauth2accesstoken --password ${var.build_args_default.TOKEN_SA} https://${region}-docker.pkg.dev"
    ])
  }
  triggers = {
    resource_id = terraform_data.trigger[0].input
  }
  depends_on = [google_artifact_registry_repository.repo]
}

# Docker Mount Files
resource "null_resource" "docker_mount" {
  for_each = { for entry in local.COMMANDS_ARGS.mount : "${entry.source}" => entry }
  provisioner "local-exec" {
    command = "mkdir -p ${each.value.path} && cp ${each.value.source} ${each.value.target}"
  }
  triggers   = { resource_id = terraform_data.trigger[0].input }
  depends_on = [google_artifact_registry_repository.repo]
}

# Build
resource "null_resource" "docker_build" {
  count = var.image_name != null ? 1 : 0
  provisioner "local-exec" {
    command = "docker image build -f ${local.COMMANDS_ARGS.dockerfile} ${var.context}/ ${local.COMMANDS_ARGS.tags} ${local.COMMANDS_ARGS.build} ${local.COMMANDS_ARGS.others}"
  }
  triggers   = { resource_id = terraform_data.trigger[0].input }
  depends_on = [null_resource.docker_login, null_resource.docker_mount]
}

# Push docker image
resource "null_resource" "docker_push" {
  for_each = var.tag_treated
  provisioner "local-exec" {
    command = "docker push ${var.image_name}:${each.value}"
  }
  triggers   = { resource_id = terraform_data.trigger[0].input }
  depends_on = [null_resource.docker_build]
}
