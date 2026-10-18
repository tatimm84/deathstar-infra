# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# COMPOSER
# --------------------------------------------------------------------
locals {
  composer = module.json_composer_reader.parsed_data

  composer_files_reader = module.composer_files_reader.parsed_data
  composer_files = [
    for item in local.composer_files_reader : {
      file = item.source
      name = replace(item.full_name, "${item.path_name}/", "")
      bucket = lookup(jsondecode(templatefile(
        "${var.SRC_INFRA_PATH}/gcp/auto/composer/${item.path_name_raw}.json",
        {
          "__project_number__" = var.PROJECT_NUMBER,
          "__project_name__"   = var.GCP_PROJECT,
          "__region__"         = var.GCP_REGION,
          "__env__"            = var.ENVIRONMENT,
          "__uid_now__"        = var.UID_NOW
        })),
        "composer_bucket", ""
      ),
      templates = "${var.SRC_INFRA_PATH}/gcp/auto/composer/${item.path_name_raw}/config/templates"
      content   = item.content_raw
    }
  ]

  nonutf8_composer_files_reader = module.nonutf8_composer_files_reader.parsed_data
  nonutf8_composer_files = [
    for item in local.nonutf8_composer_files_reader : {
      file = item.source
      name = replace(item.full_name, "${item.path_name}/", "")
      bucket = lookup(jsondecode(templatefile(
        "${var.SRC_INFRA_PATH}/gcp/auto/composer/${item.path_name_raw}.json",
        {
          "__project_number__" = var.PROJECT_NUMBER,
          "__project_name__"   = var.GCP_PROJECT,
          "__region__"         = var.GCP_REGION,
          "__env__"            = var.ENVIRONMENT,
          "__uid_now__"        = var.UID_NOW
        })),
        "composer_bucket", ""
      ),
      templates = "${var.SRC_INFRA_PATH}/gcp/auto/composer/${item.path_name_raw}/config/templates"
      content   = item.content_raw
    }
  ]

  config_files_reader = module.json_composer_config_reader.parsed_data
  config_files = distinct(flatten([
    for item in local.config_files_reader : [
      for i in range(length(lookup(jsondecode(file("${var.SRC_INFRA_PATH}/gcp/auto/composer/${item.source}")), "airflow_dags", []))) : {
        file  = item.source
        count = i
        name  = replace(item.full_name, "${item.path_name}/", "")
        bucket = lookup(jsondecode(templatefile(
          "${var.SRC_INFRA_PATH}/gcp/auto/composer/${item.path_name_raw}.json",
          {
            "__project_number__" = var.PROJECT_NUMBER,
            "__project_name__"   = var.GCP_PROJECT,
            "__region__"         = var.GCP_REGION,
            "__env__"            = var.ENVIRONMENT,
            "__uid_now__"        = var.UID_NOW
          })),
          "composer_bucket", ""
        ),
        templates = "${var.SRC_INFRA_PATH}/gcp/auto/composer/${item.path_name_raw}/config/templates"
        content   = item.content
        prefix = replace(
          replace(
            "${join("/", slice(split("/", item.source), 1, length(split("/", item.source)) - 1))}",
            "__env__", var.ENVIRONMENT
        ), "/config/", "dags")
      }
    ]
  ]))
}

module "json_composer_reader" {
  source = "./modules/utils/reader"

  source_path = "${var.SRC_INFRA_PATH}/gcp/auto/composer/"
  enviroment  = var.ENVIRONMENT
  files_regex = "*"
  template_vars = {
    "__project_number__" = var.PROJECT_NUMBER,
    "__project_name__"   = var.GCP_PROJECT,
    "__region__"         = var.GCP_REGION,
    "__env__"            = var.ENVIRONMENT,
    "__uid_now__"        = var.UID_NOW
  }
}

module "composer_files_reader" {
  source = "./modules/utils/reader"

  source_path = "${var.SRC_INFRA_PATH}/gcp/auto/composer/"
  enviroment  = var.ENVIRONMENT
  files_regex = "[^.]**/**/*.{py,json,sql,txt,csv}"
  is_json     = false
  is_utf8     = true
  template_vars = {
    "__project_number__" = var.PROJECT_NUMBER,
    "__project_name__"   = var.GCP_PROJECT,
    "__region__"         = var.GCP_REGION,
    "__env__"            = var.ENVIRONMENT,
    "__uid_now__"        = var.UID_NOW
  }
}

module "nonutf8_composer_files_reader" {
  source = "./modules/utils/reader"

  source_path = "${var.SRC_INFRA_PATH}/gcp/auto/composer/"
  enviroment  = var.ENVIRONMENT
  files_regex = "[^.]**/**/*.{jar}"
  is_json     = false
  is_utf8     = false
  template_vars = {
    "__project_number__" = var.PROJECT_NUMBER,
    "__project_name__"   = var.GCP_PROJECT,
    "__region__"         = var.GCP_REGION,
    "__env__"            = var.ENVIRONMENT,
    "__uid_now__"        = var.UID_NOW
  }
}

module "json_composer_config_reader" {
  source = "./modules/utils/reader"

  source_path = "${var.SRC_INFRA_PATH}/gcp/auto/composer/"
  enviroment  = var.ENVIRONMENT
  files_regex = "[^.]**/**/**.json"
  template_vars = {
    "__project_number__" = var.PROJECT_NUMBER,
    "__project_name__"   = var.GCP_PROJECT,
    "__region__"         = var.GCP_REGION,
    "__env__"            = var.ENVIRONMENT,
    "__uid_now__"        = var.UID_NOW
  }
}

module "gcp_composer" {
  for_each         = { for entry in local.composer : "${entry.source}" => entry }
  source           = "./modules/gcp/composer"
  gcp_project      = var.GCP_PROJECT
  gcp_region       = lookup(each.value.content, "location", "") != "" ? lookup(each.value.content, "location") : var.GCP_REGION
  composer_version = lookup(each.value.content, "composer_version", "") != "" ? lookup(each.value.content, "composer_version") : null
  name             = each.value.file_name
  labels           = lookup(each.value.content, "labels", {}) != {} ? lookup(each.value.content, "labels") : null
  config           = lookup(each.value.content, "config", {}) != {} ? [lookup(each.value.content, "config")] : []
  storage_config   = lookup(each.value.content, "storage_config", {}) != {} ? [lookup(each.value.content, "storage_config")] : []
  depends_on       = [module.gcp_apis_services]
}

# Composer files but config and libs to GCS
module "gcp_composer_dags" {
  for_each = {
    for entry in local.composer_files : "${entry.file}" => entry
    if(length(split("/config/", "${entry.file}")) == 1 && length(split("/libs/", "${entry.file}")) == 1)
  }
  source        = "./modules/gcp/cloud_storage"
  bucket_create = false
  bucket        = each.value.bucket
  name          = each.value.name
  content       = each.value.content
  depends_on    = [module.gcp_composer, module.gcp_cloud_storage_bucket]
}

# Non UTF-8 composer files like .jar files
module "gcp_composer_nontuf8" {
  for_each = {
    for entry in local.nonutf8_composer_files : "${entry.file}" => entry
    if(length(split("/config/", "${entry.file}")) == 1 && length(split("/libs/", "${entry.file}")) == 1)
  }
  source        = "./modules/gcp/cloud_storage"
  bucket_create = false
  bucket        = each.value.bucket
  name          = each.value.name
  content       = each.value.content
  object_source = "${var.SRC_INFRA_PATH}/gcp/auto/composer/${each.value.file}"
  depends_on    = [module.gcp_composer, module.gcp_cloud_storage_bucket]
}

# Composer libs files to GCS
data "archive_file" "libs" {
  for_each    = { for entry in local.composer_files : "${entry.file}" => entry if length(split("/libs/", "${entry.file}")) > 1 }
  type        = "zip"
  source_dir  = join("/", ["${var.SRC_INFRA_PATH}/gcp/composer", each.value.file])
  output_path = "temp/${each.value}.zip"
  excludes    = ["main.py", "requirements.txt", "README.MD"]
}

module "gcp_composer_libs" {
  for_each      = { for entry in local.composer_files : "${entry.file}" => entry if length(split("/libs/", "${entry.file}")) > 1 }
  source        = "./modules/gcp/cloud_storage"
  bucket_create = false
  bucket        = each.value.bucket
  name          = replace(join("/", ["${var.SRC_INFRA_PATH}/gcp/composer", each.value.file]), "__env__", var.ENVIRONMENT)
  object_source = data.archive_file.libs[each.value.file].output_path
  depends_on    = [module.gcp_composer, module.gcp_cloud_storage_bucket]
}

module "gcp_composer_config" {
  for_each      = { for entry in local.config_files : "${entry.file}_${entry.count}" => entry if(length(split("/config/", "${entry.file}")) > 1 && length(split("/pip/", "${entry.file}")) == 1 && length(split("/templates/", "${entry.file}")) == 1) }
  source        = "./modules/gcp/cloud_storage"
  bucket_create = false
  bucket        = each.value.bucket
  name          = "${each.value.prefix}/${replace(try(each.value.content["airflow_dags"][each.value.count]["__dag_id__"], null), "__env__", var.ENVIRONMENT)}"
  content       = replace(join(" ", [for word in split(" ", file("${each.value.templates}/${try(each.value.content["airflow_dags"][each.value.count]["__template__"], null)}")) : try(each.value.content["airflow_dags"][each.value.count][word], word)]), "__env__", "${var.ENVIRONMENT}")
  depends_on    = [module.gcp_composer, module.gcp_cloud_storage_bucket]
}
