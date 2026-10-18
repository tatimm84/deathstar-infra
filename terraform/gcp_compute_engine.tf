# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# COMPUTE ENGINE
# --------------------------------------------------------------------
locals {
  compute_engine_reader = module.json_compute_reader.parsed_data
  compute_engine = distinct(flatten([
    for item in local.compute_engine_reader : [
      for i in range(lookup(item.content, "machine_count")) : {
        file    = item.source
        count   = i
        name    = item.file_name
        content = item.content
      }
    ]
  ]))
}

module "json_compute_reader" {
  source = "./modules/utils/reader"

  source_path = "${var.SRC_INFRA_PATH}/gcp/auto/compute_engine/"
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


module "gcp_compute_engine_instance" {
  for_each                     = { for entry in local.compute_engine : "${entry.file}_${entry.count}" => entry }
  source                       = "./modules/gcp/compute_engine"
  gcp_project                  = var.GCP_PROJECT
  gcp_region                   = lookup(each.value.content, "location", "") != "" ? lookup(each.value.content, "location") : "${var.GCP_REGION}"
  gcp_zone                     = lookup(each.value.content, "zone", "") != "" ? lookup(each.value.content, "zone") : "${var.GCP_REGION}-b"
  name                         = lookup(each.value.content, "machine_count") == 1 ? "${each.value.name}" : "${each.value.name}-${each.value.count}"
  machine_type                 = lookup(each.value.content, "machine_type")
  allow_stopping_for_update    = lookup(each.value.content, "allow_stopping_for_update", "") != "" ? lookup(each.value.content, "allow_stopping_for_update") : null
  deletion_protection          = lookup(each.value.content, "deletion_protection", "") != "" ? lookup(each.value.content, "deletion_protection") : null
  description                  = lookup(each.value.content, "description", "") != "" ? lookup(each.value.content, "description") : null
  desired_status               = lookup(each.value.content, "desired_status", "") != "" ? lookup(each.value.content, "desired_status") : null
  enable_display               = lookup(each.value.content, "enable_display", "") != "" ? lookup(each.value.content, "enable_display") : null
  hostname                     = lookup(each.value.content, "hostname", "") != "" ? lookup(each.value.content, "hostname") : null
  labels                       = lookup(each.value.content, "labels", {}) != {} ? lookup(each.value.content, "labels") : null
  metadata                     = lookup(each.value.content, "metadata", {}) != {} ? lookup(each.value.content, "metadata") : null
  metadata_startup_script      = lookup(each.value.content, "metadata_startup_script", "") != "" ? lookup(each.value.content, "metadata_startup_script") : null
  min_cpu_platform             = lookup(each.value.content, "min_cpu_platform", "") != "" ? lookup(each.value.content, "min_cpu_platform") : null
  resource_policies            = lookup(each.value.content, "resource_policies", []) != [] ? lookup(each.value.content, "resource_policies") : null
  tags                         = lookup(each.value.content, "tags", []) != [] ? lookup(each.value.content, "tags") : null
  boot_disk                    = lookup(each.value.content, "boot_disk", {}) != {} ? [lookup(each.value.content, "boot_disk")] : []
  scratch_disk                 = lookup(each.value.content, "scratch_disk", {}) != {} ? [lookup(each.value.content, "scratch_disk")] : []
  attached_disk                = lookup(each.value.content, "attached_disk", {}) != {} ? [lookup(each.value.content, "attached_disk")] : []
  network_interface            = lookup(each.value.content, "network_interface", {}) != {} ? [lookup(each.value.content, "network_interface")] : []
  service_account              = lookup(each.value.content, "service_account", {}) != {} ? [lookup(each.value.content, "service_account")] : []
  scheduling                   = lookup(each.value.content, "scheduling", {}) != {} ? [lookup(each.value.content, "scheduling")] : []
  guest_accelerator            = lookup(each.value.content, "guest_accelerator", {}) != {} ? [lookup(each.value.content, "guest_accelerator")] : []
  shielded_instance_config     = lookup(each.value.content, "shielded_instance_config", {}) != {} ? [lookup(each.value.content, "shielded_instance_config")] : []
  confidential_instance_config = lookup(each.value.content, "confidential_instance_config", {}) != {} ? [lookup(each.value.content, "confidential_instance_config")] : []
  advanced_machine_features    = lookup(each.value.content, "advanced_machine_features", {}) != {} ? [lookup(each.value.content, "advanced_machine_features")] : []
  reservation_affinity         = lookup(each.value.content, "reservation_affinity", {}) != {} ? [lookup(each.value.content, "reservation_affinity")] : []
  instance_schedule_name       = lookup(each.value.content, "instance_schedule_name", "") != "" ? lookup(each.value.content, "instance_schedule_name") : null
  schedule_description         = lookup(each.value.content, "schedule_description", "") != "" ? lookup(each.value.content, "schedule_description") : null
  snapshot_schedule_policy     = lookup(each.value.content, "snapshot_schedule_policy", {}) != {} ? [lookup(each.value.content, "snapshot_schedule_policy")] : []
  group_placement_policy       = lookup(each.value.content, "group_placement_policy", {}) != {} ? [lookup(each.value.content, "group_placement_policy")] : []
  instance_schedule_policy     = lookup(each.value.content, "instance_schedule_policy", {}) != {} ? [lookup(each.value.content, "instance_schedule_policy")] : []
  attach_schedule              = lookup(each.value.content, "attach_schedule", "") != "" ? lookup(each.value.content, "attach_schedule") : false
  iam_type                     = lookup(each.value.content, "iam_type", "") != "" ? lookup(each.value.content, "iam_type") : null
  iam_member                   = lookup(each.value.content, "iam_member", "") != "" ? lookup(each.value.content, "iam_member") : null
  iam_members                  = lookup(each.value.content, "iam_members", []) != [] ? lookup(each.value.content, "iam_members") : null
  iam_condition                = lookup(each.value.content, "iam_condition", {}) != {} ? [lookup(each.value.content, "iam_condition")] : []
  depends_on                   = [module.gcp_apis_services, module.gcp_vpc_network]
}
