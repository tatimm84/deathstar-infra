# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# CLOUD SQL DATABASE
# --------------------------------------------------------------------
locals {
  sql_database = module.json_sql_reader.parsed_data
}

module "json_sql_reader" {
  source = "./modules/utils/reader"

  source_path = "${var.SRC_INFRA_PATH}/gcp/auto/sql_database/"
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

module "sql_database" {
  for_each                  = { for entry in local.sql_database : "${entry.source}" => entry }
  source                    = "./modules/gcp/sql_database"
  gcp_project               = var.GCP_PROJECT
  sql_instance_create       = lookup(each.value.content, "sql_instance_create", null) != null ? lookup(each.value.content, "sql_instance_create") : true
  sql_instance_name         = lookup(each.value.content, "sql_instance_name", "") != "" ? lookup(each.value.content, "sql_instance_name") : null
  database_version          = lookup(each.value.content, "database_version", "") != "" ? lookup(each.value.content, "database_version") : null
  deletion_protection       = lookup(each.value.content, "deletion_protection", null) != null ? lookup(each.value.content, "deletion_protection") : false
  sql_instance_settings     = lookup(each.value.content, "sql_instance_settings", {}) != {} ? [lookup(each.value.content, "sql_instance_settings")] : []
  sql_db_name               = lookup(each.value.content, "sql_db_name", "") != "" ? lookup(each.value.content, "sql_db_name") : null
  sql_certs_name            = lookup(each.value.content, "sql_certs_name", "") != "" ? lookup(each.value.content, "sql_certs_name") : null
  sql_user_name             = lookup(each.value.content, "sql_user_name", "") != "" ? lookup(each.value.content, "sql_user_name") : null
  sql_user_pw               = var.SQL_USER_PW
  sql_secret_client_key     = lookup(each.value.content, "sql_secret_client_key", "") != "" ? lookup(each.value.content, "sql_secret_client_key") : null
  sql_secret_client_pem     = lookup(each.value.content, "sql_secret_client_pem", "") != "" ? lookup(each.value.content, "sql_secret_client_pem") : null
  sql_secret_server_ca_cert = lookup(each.value.content, "sql_secret_server_ca_cert", "") != "" ? lookup(each.value.content, "sql_secret_server_ca_cert") : null
  depends_on                = [module.gcp_apis_services, module.gcp_vpc_network]
}
