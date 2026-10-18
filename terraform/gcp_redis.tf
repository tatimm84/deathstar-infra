# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# REDIS
# --------------------------------------------------------------------
locals {
  redis = module.json_redis_reader.parsed_data
}

module "json_redis_reader" {
  source = "./modules/utils/reader"

  source_path = "${var.SRC_INFRA_PATH}/gcp/auto/redis/"
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

module "gcp_redis_instance" {
  for_each                = { for entry in local.redis : "${entry.source}" => entry }
  source                  = "./modules/gcp/redis"
  gcp_project             = var.GCP_PROJECT
  gcp_region              = lookup(each.value.content, "location", "") != "" ? lookup(each.value.content, "location") : var.GCP_REGION
  name                    = each.value.file_name
  memory_size_gb          = lookup(each.value.content, "memory_size_gb")
  alternative_location_id = lookup(each.value.content, "alternative_location_id", "") != "" ? lookup(each.value.content, "alternative_location_id") : null
  auth_enabled            = lookup(each.value.content, "auth_enabled", "") != "" ? lookup(each.value.content, "auth_enabled") : null
  authorized_network      = lookup(each.value.content, "authorized_network", "") != "" ? lookup(each.value.content, "authorized_network") : null
  connect_mode            = lookup(each.value.content, "connect_mode", "") != "" ? lookup(each.value.content, "connect_mode") : null
  customer_managed_key    = lookup(each.value.content, "customer_managed_key", "") != "" ? lookup(each.value.content, "customer_managed_key") : null
  display_name            = lookup(each.value.content, "display_name", "") != "" ? lookup(each.value.content, "display_name") : null
  labels                  = lookup(each.value.content, "labels", {}) != {} ? lookup(each.value.content, "labels") : null
  location_id             = lookup(each.value.content, "location_id", "") != "" ? lookup(each.value.content, "location_id") : null
  read_replicas_mode      = lookup(each.value.content, "read_replicas_mode", "") != "" ? lookup(each.value.content, "read_replicas_mode") : null
  redis_configs           = lookup(each.value.content, "redis_configs", {}) != {} ? lookup(each.value.content, "redis_configs") : null
  redis_version           = lookup(each.value.content, "redis_version", "") != "" ? lookup(each.value.content, "redis_version") : null
  replica_count           = lookup(each.value.content, "replica_count", "") != "" ? lookup(each.value.content, "replica_count") : null
  reserved_ip_range       = lookup(each.value.content, "reserved_ip_range", "") != "" ? lookup(each.value.content, "reserved_ip_range") : null
  secondary_ip_range      = lookup(each.value.content, "secondary_ip_range", "") != "" ? lookup(each.value.content, "secondary_ip_range") : null
  tier                    = lookup(each.value.content, "tier", "") != "" ? lookup(each.value.content, "tier") : null
  transit_encryption_mode = lookup(each.value.content, "transit_encryption_mode", "") != "" ? lookup(each.value.content, "transit_encryption_mode") : null
  maintenance_policy      = lookup(each.value.content, "maintenance_policy", {}) != {} ? [lookup(each.value.content, "maintenance_policy")] : []
  persistence_config      = lookup(each.value.content, "persistence_config", {}) != {} ? [lookup(each.value.content, "persistence_config")] : []
  depends_on              = [module.gcp_apis_services, module.gcp_vpc_network]
}
