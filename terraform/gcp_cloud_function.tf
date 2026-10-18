# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# CLOUD FUNCTIONS
# --------------------------------------------------------------------
locals {
  default_template_vars = {
    "__project_number__"          = var.PROJECT_NUMBER,
    "__project_name__"            = var.GCP_PROJECT,
    "__region__"                  = var.GCP_REGION,
    "__running_service_account__" = var.RUNNING_SERVICE_ACCOUNT,
    "__env__"                     = var.ENVIRONMENT,
    "__uid_now__"                 = var.UID_NOW,
  }
  function_files = module.json_functions_reader.parsed_data

  functions = [
    for item in local.function_files : {
      file          = item.source
      name          = item.file_name
      code_path     = lookup(item.content, "code_path", "${var.SRC_CODE_PATH}/${item.file_name}")
      object_prefix = "cloud_functions/${item.file_name}/src-"
      content = jsondecode(templatefile(
        "${var.SRC_INFRA_PATH}/gcp/auto/cloud_functions/${item.source}",
        {
          "__project_number__"          = var.PROJECT_NUMBER,
          "__project_name__"            = var.GCP_PROJECT,
          "__region__"                  = var.GCP_REGION,
          "__running_service_account__" = var.RUNNING_SERVICE_ACCOUNT,
          "__env__"                     = var.ENVIRONMENT,
          "__uid_now__"                 = var.UID_NOW
        }
      ))
    }
  ]
}


module "json_functions_reader" {
  source = "./modules/utils/reader"

  source_path = "${var.SRC_INFRA_PATH}/gcp/auto/cloud_functions/"
  enviroment  = var.ENVIRONMENT
  files_regex = "**"
  template_vars = {
    "__project_number__" = var.PROJECT_NUMBER,
    "__project_name__"   = var.GCP_PROJECT,
    "__region__"         = var.GCP_REGION,
    "__env__"            = var.ENVIRONMENT,
    "__uid_now__"        = var.UID_NOW
  }
}

module "gcp_cloud_function" {
  for_each                      = { for entry in local.functions : "${entry.file}" => entry }
  source                        = "./modules/gcp/cloud_functions"
  gcp_project                   = var.GCP_PROJECT
  gcp_region                    = lookup(each.value.content, "location", "") != "" ? lookup(each.value.content, "location") : var.GCP_REGION
  source_dir                    = each.value.code_path
  bucket                        = lookup(each.value.content, "bucket")
  object_prefix                 = each.value.object_prefix
  name                          = each.value.name
  generation                    = lookup(each.value.content, "generation", "") != "" ? lookup(each.value.content, "generation") : 1
  runtime                       = lookup(each.value.content, "runtime", "") != "" ? lookup(each.value.content, "runtime") : null
  available_memory_mb           = lookup(each.value.content, "available_memory_mb", "") != "" ? lookup(each.value.content, "available_memory_mb") : null
  build_worker_pool             = lookup(each.value.content, "build_worker_pool", "") != "" ? lookup(each.value.content, "build_worker_pool") : null
  description                   = lookup(each.value.content, "description", "") != "" ? lookup(each.value.content, "description") : null
  docker_registry               = lookup(each.value.content, "docker_registry", "") != "" ? lookup(each.value.content, "docker_registry") : null
  docker_repository             = lookup(each.value.content, "docker_repository", "") != "" ? lookup(each.value.content, "docker_repository") : null
  entry_point                   = lookup(each.value.content, "entry_point", "") != "" ? lookup(each.value.content, "entry_point") : null
  environment_variables         = lookup(each.value.content, "environment_variables", {}) != {} ? lookup(each.value.content, "environment_variables") : null
  https_trigger_security_level  = lookup(each.value.content, "trigger_http", false) ? lookup(each.value.content, "https_trigger_security_level", "SECURE_ALWAYS") : null
  ingress_settings              = lookup(each.value.content, "ingress_settings", "") != "" ? lookup(each.value.content, "ingress_settings") : null
  kms_key_name                  = lookup(each.value.content, "kms_key_name", "") != "" ? lookup(each.value.content, "kms_key_name") : null
  labels                        = lookup(each.value.content, "labels", {}) != {} ? lookup(each.value.content, "labels") : null
  max_instances                 = lookup(each.value.content, "max_instances", "") != "" ? lookup(each.value.content, "max_instances") : null
  min_instances                 = lookup(each.value.content, "min_instances", "") != "" ? lookup(each.value.content, "min_instances") : null
  service_account_email         = lookup(each.value.content, "service_account_email", "") != "" ? lookup(each.value.content, "service_account_email") : null
  timeout                       = lookup(each.value.content, "timeout", "") != "" ? lookup(each.value.content, "timeout") : null
  trigger_http                  = lookup(each.value.content, "trigger_http", false) ? lookup(each.value.content, "trigger_http") : null
  vpc_connector                 = lookup(each.value.content, "vpc_connector", "") != "" ? lookup(each.value.content, "vpc_connector") : null
  vpc_connector_egress_settings = lookup(each.value.content, "vpc_connector", "") != "" ? lookup(each.value.content, "vpc_connector_egress_settings") : null
  build_config                  = lookup(each.value.content, "build_config", {}) != {} ? [lookup(each.value.content, "build_config")] : []
  event_trigger                 = lookup(each.value.content, "event_trigger", {}) != {} ? [lookup(each.value.content, "event_trigger")] : []
  secret_environment_variables  = lookup(each.value.content, "secret_environment_variables", {}) != {} ? [lookup(each.value.content, "secret_environment_variables")] : []
  secret_volumes                = lookup(each.value.content, "secret_volumes", {}) != {} ? [lookup(each.value.content, "secret_volumes")] : []
  service_config                = lookup(each.value.content, "service_config", {}) != {} ? [lookup(each.value.content, "service_config")] : []
  source_repository             = lookup(each.value.content, "source_repository", {}) != {} ? [lookup(each.value.content, "source_repository")] : []
  file_replace_regex            = lookup(each.value.content, "file_replace_regex", "") != "" ? lookup(each.value.content, "file_replace_regex") : "**"
  template_vars                 = merge(local.default_template_vars, lookup(each.value.content, "template_vars", {}))
  depends_on                    = [module.gcp_apis_services, module.gcp_cloud_storage_bucket, module.gcp_artifact_registry_image]
}
