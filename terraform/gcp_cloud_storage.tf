# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# CLOUD STORAGE
# --------------------------------------------------------------------
locals {
  bucket = module.json_bucket_reader.parsed_data

  object_files = module.objects_reader.parsed_data
  object = [
    for item in local.object_files : {
      file    = item.source
      bucket  = item.path_name
      name    = replace(item.full_name, "${item.path_name}/", "")
      source  = "${var.SRC_INFRA_PATH}/gcp/auto/cloud_storage/${item.source}"
      content = item.content_raw
    }
  ]

  bkp_files = module.json_bkp_objects_reader.parsed_data
  object_backup = distinct(flatten([
    for item in local.bkp_files : [
      for i in range(length(lookup(item.content, "files", []))) : {
        file   = "${item.source}_${i}"
        bucket = item.content["bucket"]
        name   = lookup(item.content, "files", [])[i]["target"]
        source = lookup(item.content, "files", [])[i]["source"]
      }
    ]
  ]))
}

module "json_bucket_reader" {
  source = "./modules/utils/reader"

  source_path = "${var.SRC_INFRA_PATH}/gcp/auto/cloud_storage/"
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

module "objects_reader" {
  source = "./modules/utils/reader"

  source_path = "${var.SRC_INFRA_PATH}/gcp/auto/cloud_storage/"
  enviroment  = var.ENVIRONMENT
  files_regex = "[^.]**/**"
  template_vars = {
    "__project_number__" = var.PROJECT_NUMBER,
    "__project_name__"   = var.GCP_PROJECT,
    "__region__"         = var.GCP_REGION,
    "__env__"            = var.ENVIRONMENT,
    "__uid_now__"        = var.UID_NOW
  }
}

module "json_bkp_objects_reader" {
  source = "./modules/utils/reader"

  source_path = "${var.SRC_INFRA_PATH}/gcp/auto/cloud_storage_backup/"
  enviroment  = var.ENVIRONMENT
  files_regex = "**"
  template_vars = {
    "__project_number__" = var.PROJECT_NUMBER,
    "__project_name__"   = var.GCP_PROJECT,
    "__region__"         = var.GCP_REGION,
    "__env__"            = var.ENVIRONMENT,
    "__uid_now__"        = var.UID_NOW
    "__infra__"          = var.SRC_INFRA_PATH,
    "__source__"         = var.SRC_CODE_PATH,
    "__doc__"            = var.SRC_DOCS_PATH
  }
}

module "gcp_cloud_storage_bucket" {
  for_each                    = { for entry in local.bucket : "${entry.source}" => entry }
  source                      = "./modules/gcp/cloud_storage"
  gcp_project                 = var.GCP_PROJECT
  gcp_region                  = lookup(each.value.content, "location", "") != "" ? lookup(each.value.content, "location") : var.GCP_REGION
  bucket_create               = true
  object_create               = false
  bucket                      = each.value.file_name
  default_event_based_hold    = lookup(each.value.content, "default_event_based_hold", "") != "" ? lookup(each.value.content, "default_event_based_hold") : null
  enable_object_retention     = lookup(each.value.content, "enable_object_retention", "") != "" ? lookup(each.value.content, "enable_object_retention") : null
  force_destroy               = lookup(each.value.content, "force_destroy", "") != "" ? lookup(each.value.content, "force_destroy") : null
  labels                      = lookup(each.value.content, "labels", {}) != {} ? lookup(each.value.content, "labels") : null
  public_access_prevention    = lookup(each.value.content, "public_access_prevention", "") != "" ? lookup(each.value.content, "public_access_prevention") : null
  requester_pays              = lookup(each.value.content, "requester_pays", "") != "" ? lookup(each.value.content, "requester_pays") : null
  rpo                         = lookup(each.value.content, "rpo", "") != "" ? lookup(each.value.content, "rpo") : null
  storage_class_bucket        = lookup(each.value.content, "storage_class", "") != "" ? lookup(each.value.content, "storage_class") : null
  uniform_bucket_level_access = lookup(each.value.content, "uniform_bucket_level_access", "") != "" ? lookup(each.value.content, "uniform_bucket_level_access") : null
  autoclass                   = lookup(each.value.content, "autoclass", {}) != {} ? [lookup(each.value.content, "autoclass")] : []
  cors                        = lookup(each.value.content, "cors", {}) != {} ? [lookup(each.value.content, "cors")] : []
  custom_placement_config     = lookup(each.value.content, "custom_placement_config", {}) != {} ? [lookup(each.value.content, "custom_placement_config")] : []
  encryption                  = lookup(each.value.content, "encryption", {}) != {} ? [lookup(each.value.content, "encryption")] : []
  lifecycle_rule              = lookup(each.value.content, "lifecycle_rule", {}) != {} ? [lookup(each.value.content, "lifecycle_rule")] : []
  logging                     = lookup(each.value.content, "logging", {}) != {} ? [lookup(each.value.content, "logging")] : []
  retention_policy            = lookup(each.value.content, "retention_policy", {}) != {} ? [lookup(each.value.content, "retention_policy")] : []
  soft_delete_policy          = lookup(each.value.content, "soft_delete_policy", {}) != {} ? [lookup(each.value.content, "soft_delete_policy")] : []
  versioning                  = lookup(each.value.content, "versioning", {}) != {} ? [lookup(each.value.content, "versioning")] : []
  website                     = lookup(each.value.content, "website", {}) != {} ? [lookup(each.value.content, "website")] : []
  acl_role                    = lookup(each.value.content, "acl_role", {}) != {} ? lookup(each.value.content, "acl_role") : null
  acl_entity                  = lookup(each.value.content, "acl_entity", {}) != {} ? lookup(each.value.content, "acl_entity") : null
}

module "gcp_cloud_storage_object" {
  for_each      = { for entry in local.object : "${entry.file}" => entry }
  source        = "./modules/gcp/cloud_storage"
  gcp_project   = var.GCP_PROJECT
  gcp_region    = var.GCP_REGION
  bucket_create = false
  object_create = true
  bucket        = each.value.bucket
  name          = each.value.name
  object_source = each.value.content != null ? null : each.value.source
  content       = each.value.content
  depends_on    = [module.gcp_cloud_storage_bucket]
}

module "gcp_cloud_storage_object_backup" {
  for_each      = { for entry in local.object_backup : "${entry.file}" => entry }
  source        = "./modules/gcp/cloud_storage"
  gcp_project   = var.GCP_PROJECT
  gcp_region    = var.GCP_REGION
  bucket_create = false
  object_create = true
  bucket        = each.value.bucket
  name          = each.value.name
  object_source = each.value.source
  depends_on    = [module.gcp_cloud_storage_bucket]
}
