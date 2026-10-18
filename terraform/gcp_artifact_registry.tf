# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# ARTIFACT REGISTRY
# --------------------------------------------------------------------
locals {
  repos = module.json_repos_reader.parsed_data

  images_files = module.json_images_reader.parsed_data
  images = [
    for item in local.images_files : {
      file       = item.source
      image_name = "${var.GCP_REGION}-docker.pkg.dev/${var.GCP_PROJECT}/${item.path_name}/${item.file_name}"
      context    = lookup(item.content, "image_path", "${var.SRC_CODE_PATH}/${item.file_name}")
      sha1_json  = item.sha1_json
      content = jsondecode(templatefile(
        "${var.SRC_INFRA_PATH}/gcp/auto/artifact_registry/${item.source}",
        {
          "__project_number__" = var.PROJECT_NUMBER,
          "__project_name__"   = var.GCP_PROJECT,
          "__region__"         = var.GCP_REGION,
          "__env__"            = var.ENVIRONMENT,
          "__uid_now__"        = var.UID_NOW,
          "__sha1__" = sha1(join("", [
            for f in fileset(lookup(item.content, "image_path", "${var.SRC_CODE_PATH}/${item.file_name}"), "**") :
            filesha1("${lookup(item.content, "image_path", "${var.SRC_CODE_PATH}/${item.file_name}")}/${f}")
          ]))
        }
      ))
    }
  ]
}

module "json_repos_reader" {
  source = "./modules/utils/reader"

  source_path = "${var.SRC_INFRA_PATH}/gcp/auto/artifact_registry/"
  enviroment  = var.ENVIRONMENT
  files_regex = "*"
  template_vars = {
    "__project_number__" = var.PROJECT_NUMBER,
    "__project_name__"   = var.GCP_PROJECT,
    "__region__"         = var.GCP_REGION,
    "__env__"            = var.ENVIRONMENT,
    "__uid_now__"        = var.UID_NOW,
    "__sha1__"           = "__sha1__"
  }
}

module "json_images_reader" {
  source = "./modules/utils/reader"

  source_path = "${var.SRC_INFRA_PATH}/gcp/auto/artifact_registry/"
  enviroment  = var.ENVIRONMENT
  files_regex = "[^.]**/[^.]*.json"
  template_vars = {
    "__project_number__" = var.PROJECT_NUMBER,
    "__project_name__"   = var.GCP_PROJECT,
    "__region__"         = var.GCP_REGION,
    "__env__"            = var.ENVIRONMENT,
    "__uid_now__"        = var.UID_NOW,
    "__sha1__"           = "__sha1__"
  }
}

module "gcp_artifact_registry_repo" {
  for_each                  = { for entry in local.repos : "${entry.source}" => entry }
  source                    = "./modules/gcp/artifact_registry"
  gcp_project               = var.GCP_PROJECT
  gcp_region                = lookup(each.value.content, "location", "") != "" ? lookup(each.value.content, "location") : var.GCP_REGION
  repository_create         = true
  repository_id             = each.value.file_name
  format                    = lookup(each.value.content, "format", "") != "" ? lookup(each.value.content, "format") : null
  cleanup_policy_dry_run    = lookup(each.value.content, "cleanup_policy_dry_run", "") != "" ? lookup(each.value.content, "cleanup_policy_dry_run") : null
  description               = lookup(each.value.content, "description", "") != "" ? lookup(each.value.content, "description") : null
  kms_key_name              = lookup(each.value.content, "kms_key_name", "") != "" ? lookup(each.value.content, "kms_key_name") : null
  mode                      = lookup(each.value.content, "mode", "") != "" ? lookup(each.value.content, "mode") : null
  cleanup_policies          = lookup(each.value.content, "cleanup_policies", {}) != {} ? [lookup(each.value.content, "cleanup_policies")] : []
  docker_config             = lookup(each.value.content, "docker_config", {}) != {} ? [lookup(each.value.content, "docker_config")] : []
  maven_config              = lookup(each.value.content, "maven_config", {}) != {} ? [lookup(each.value.content, "maven_config")] : []
  remote_repository_config  = lookup(each.value.content, "remote_repository_config", {}) != {} ? [lookup(each.value.content, "remote_repository_config")] : []
  virtual_repository_config = lookup(each.value.content, "virtual_repository_config", {}) != {} ? [lookup(each.value.content, "virtual_repository_config")] : []
  depends_on                = [module.gcp_apis_services]
}

module "gcp_artifact_registry_image" {
  for_each           = { for entry in local.images : "${entry.file}" => entry }
  source             = "./modules/gcp/artifact_registry"
  gcp_project        = var.GCP_PROJECT
  gcp_region         = lookup(each.value.content, "location", "") != "" ? lookup(each.value.content, "location") : var.GCP_REGION
  repository_create  = false
  image_name         = each.value.image_name
  triggers           = lookup(each.value.content, "triggers", {}) != {} ? lookup(each.value.content, "triggers") : null
  login_regions      = lookup(each.value.content, "login_regions", [var.GCP_REGION])
  build              = lookup(each.value.content, "build", {})
  build_args_default = local.template_vars
  context            = each.value.context
  sha1_json          = each.value.sha1_json
  tag_treated        = lookup(lookup(each.value.content, "build", {}), "tag", []) != [] ? lookup(lookup(each.value.content, "build", {}), "tag") : []
  depends_on         = [module.gcp_apis_services, module.gcp_artifact_registry_repo]
}
