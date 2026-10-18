# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# Data Lake Ingestion - dli
# --------------------------------------------------------------------
locals {
  dli_pipelines_files  = module.json_dli_pipelines_reader.parsed_data
  dli_connectors_files = module.json_dli_connectors_reader.parsed_data
  dli_secrets_files    = module.json_dli_secrets_reader.parsed_data
  dli_operators_files  = module.json_dli_operators_reader.parsed_data
  dli_tasks_files      = module.json_dli_tasks_reader.parsed_data

  dli_dag_files = [
    for item in local.dli_pipelines_files : {
      file = item.source
      name = lookup(lookup(item.content, "dag", {}), "dag_id", item.file_name)
      content = replace(templatefile(
        "${var.SRC_CODE_PATH}/${lookup(lookup(item.content, "dag", {}), "template", "")}",
        merge(
          {
            "__pipeline_id__" : item.file_name,
            "__dag_id__" : lookup(lookup(item.content, "dag", {}), "dag_id", item.file_name),
            "__tasks_bronze__" : jsonencode(lookup(lookup(item.content, "dag", {}), "tasks_bronze", ["bronze"])),
            "__trigger_w_config__" : jsonencode(lookup(lookup(item.content, "dag", {}), "trigger_w_config", {})),
          },
          {
            for k, v in lookup(lookup(item.content, "dag", {}), "replaces", {}) :
            "__${k}__" => can(tostring(v)) ? tostring(v) : jsonencode(v)
          },
          {
            for k, v in lookup(lookup(item.content, "iac", {}), "run_job", {}) :
            "__run_job_${k}__" => can(tostring(v)) ? tostring(v) : jsonencode(v)
          },
        )
      ), "__task_file__", lookup(lookup(item.content, "dag", {}), "task_file", "default"))
    }
  ]

  dli_run_files = [
    for item in local.dli_pipelines_files : {
      file    = item.source
      content = lookup(lookup(item.content, "iac", {}), "run_job", {})
    }
  ]
}

module "json_dli_pipelines_reader" {
  source = "./modules/utils/reader"

  source_path = "${var.SRC_INFRA_PATH}/dli/auto/pipelines/"
  enviroment  = var.ENVIRONMENT
  files_regex = "**/*.json"
  template_vars = {
    "__project_number__" = var.PROJECT_NUMBER,
    "__env__"            = var.ENVIRONMENT,
    "__uid_now__"        = var.UID_NOW,
    "__project_name__"   = var.GCP_PROJECT
  }
}

module "json_dli_secrets_reader" {
  source = "./modules/utils/reader"

  source_path = "${var.SRC_INFRA_PATH}/dli/auto/secrets/"
  enviroment  = var.ENVIRONMENT
  files_regex = "**/*.json"
  template_vars = {
    "__project_number__" = var.PROJECT_NUMBER,
    "__env__"            = var.ENVIRONMENT,
    "__uid_now__"        = var.UID_NOW,
    "__project_name__"   = var.GCP_PROJECT
  }
}

module "json_dli_connectors_reader" {
  source = "./modules/utils/reader"

  source_path = "${var.SRC_INFRA_PATH}/dli/auto/connectors/"
  enviroment  = var.ENVIRONMENT
  files_regex = "**/*.json"
  template_vars = {
    "__project_number__" = var.PROJECT_NUMBER,
    "__env__"            = var.ENVIRONMENT,
    "__uid_now__"        = var.UID_NOW,
    "__project_name__"   = var.GCP_PROJECT
  }
}

module "json_dli_operators_reader" {
  source = "./modules/utils/reader"

  source_path = "${var.SRC_CODE_PATH}/templates/dags/operators/"
  enviroment  = var.ENVIRONMENT
  files_regex = "**/*.py"
  is_json     = false
  template_vars = {
    "__project_number__" = var.PROJECT_NUMBER,
    "__env__"            = var.ENVIRONMENT,
    "__uid_now__"        = var.UID_NOW,
    "__project_name__"   = var.GCP_PROJECT
  }
}

module "json_dli_tasks_reader" {
  source = "./modules/utils/reader"

  source_path = "${var.SRC_CODE_PATH}/templates/dags/tasks/"
  enviroment  = var.ENVIRONMENT
  files_regex = "**/*.py"
  is_json     = false
  template_vars = {
    "__project_number__" = var.PROJECT_NUMBER,
    "__env__"            = var.ENVIRONMENT,
    "__uid_now__"        = var.UID_NOW,
    "__project_name__"   = var.GCP_PROJECT
  }
}

module "dli_gcp_composer_dags" {
  for_each = {
    for entry in local.dli_dag_files : "${entry.file}" => entry
  }
  source        = "./modules/gcp/cloud_storage"
  bucket_create = false
  bucket        = var.DLI_COMPOSER_BUCKET
  name          = "${var.DLI_COMPOSER_DAG_PATH}/${each.value.name}.py"
  content       = each.value.content
  depends_on    = [module.gcp_cloud_storage_bucket]
}

module "dli_gcp_composer_pipelines" {
  for_each = {
    for entry in local.dli_pipelines_files : "${entry.source}" => entry
  }
  source        = "./modules/gcp/cloud_storage"
  bucket_create = false
  bucket        = var.DLI_DATAINTEGRATOR_BUCKET
  name          = "${var.DLI_DATAINTEGRATOR_PATH}/pipelines/${each.value.file_name}.json"
  content       = jsonencode(each.value.content)
  depends_on    = [module.gcp_cloud_storage_bucket]
}

module "dli_gcp_composer_secrets" {
  for_each = {
    for entry in local.dli_secrets_files : "${entry.source}" => entry
  }
  source        = "./modules/gcp/cloud_storage"
  bucket_create = false
  bucket        = var.DLI_DATAINTEGRATOR_BUCKET
  name          = "${var.DLI_DATAINTEGRATOR_PATH}/secrets/${each.value.file_name}.json"
  content       = jsonencode(each.value.content)
  depends_on    = [module.gcp_cloud_storage_bucket]
}

module "dli_gcp_composer_connectors" {
  for_each = {
    for entry in local.dli_connectors_files : "${entry.source}" => entry
  }
  source        = "./modules/gcp/cloud_storage"
  bucket_create = false
  bucket        = var.DLI_DATAINTEGRATOR_BUCKET
  name          = "${var.DLI_DATAINTEGRATOR_PATH}/connectors/${each.value.file_name}.json"
  content       = jsonencode(each.value.content)
  depends_on    = [module.gcp_cloud_storage_bucket]
}

module "dli_gcp_composer_operators" {
  for_each = {
    for entry in local.dli_operators_files : "${entry.source}" => entry
  }
  source        = "./modules/gcp/cloud_storage"
  bucket_create = false
  bucket        = var.DLI_COMPOSER_BUCKET
  name          = "plugins/operators/${each.value.file_name}.py"
  content       = each.value.content_raw
  depends_on    = [module.gcp_cloud_storage_bucket]
}

module "dli_gcp_composer_tasks" {
  for_each = {
    for entry in local.dli_tasks_files : "${entry.source}" => entry
  }
  source        = "./modules/gcp/cloud_storage"
  bucket_create = false
  bucket        = var.DLI_COMPOSER_BUCKET
  name          = "plugins/tasks/${each.value.file_name}.py"
  content       = each.value.content_raw
  depends_on    = [module.gcp_cloud_storage_bucket]
}

module "dli_gcp_cloud_run_job" {
  for_each             = { for entry in local.dli_run_files : "${entry.file}" => entry }
  source               = "./modules/gcp/cloud_run"
  gcp_project          = lookup(each.value.content, "project", "") != "" ? lookup(each.value.content, "project") : var.GCP_PROJECT
  gcp_region           = lookup(each.value.content, "region", "") != "" ? lookup(each.value.content, "region") : var.GCP_REGION
  cloud_run_type       = "job"
  name                 = lookup(each.value.content, "name", "") != "" ? lookup(each.value.content, "name") : var.GCP_REGION
  annotations          = lookup(each.value.content, "annotations", {}) != {} ? lookup(each.value.content, "annotations") : null
  client               = lookup(each.value.content, "client", "") != "" ? lookup(each.value.content, "client") : null
  client_version       = lookup(each.value.content, "client_version", "") != "" ? lookup(each.value.content, "client_version") : null
  custom_audiences     = lookup(each.value.content, "custom_audiences", []) != [] ? lookup(each.value.content, "custom_audiences") : []
  description          = lookup(each.value.content, "description", "") != "" ? lookup(each.value.content, "description") : null
  ingress              = lookup(each.value.content, "ingress", "") != "" ? lookup(each.value.content, "ingress") : null
  labels               = lookup(each.value.content, "labels", {}) != {} ? lookup(each.value.content, "labels") : null
  launch_stage         = lookup(each.value.content, "launch_stage", "") != "" ? lookup(each.value.content, "launch_stage") : null
  binary_authorization = lookup(each.value.content, "binary_authorization", {}) != {} ? [lookup(each.value.content, "binary_authorization")] : []
  traffic              = lookup(each.value.content, "traffic", {}) != {} ? [lookup(each.value.content, "traffic")] : []
  template             = lookup(each.value.content, "template", {}) != {} ? [lookup(each.value.content, "template")] : []
  iam_type             = lookup(each.value.content, "iam_type", "") != "" ? lookup(each.value.content, "iam_type") : null
  iam_member           = lookup(each.value.content, "iam_member", "") != "" ? lookup(each.value.content, "iam_member") : null
  iam_members          = lookup(each.value.content, "iam_members", []) != [] ? lookup(each.value.content, "iam_members") : null
  iam_condition        = lookup(each.value.content, "iam_condition", []) != [] ? lookup(each.value.content, "iam_condition") : []
  depends_on           = [module.gcp_apis_services]
}
