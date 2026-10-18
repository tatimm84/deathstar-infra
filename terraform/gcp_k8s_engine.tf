# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# GKE Google Kubernetes Engine
# --------------------------------------------------------------------
locals {
  k8s_engine = module.json_k8s_reader.parsed_data
}

module "json_k8s_reader" {
  source = "./modules/utils/reader"

  source_path = "${var.SRC_INFRA_PATH}/gcp/auto/k8s_engine/"
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

module "k8s_engine" {
  for_each                            = { for entry in local.k8s_engine : "${entry.source}" => entry }
  source                              = "./modules/gcp/k8s_engine"
  gcp_project                         = var.GCP_PROJECT
  gcp_region                          = var.GCP_REGION
  gke_k8s_version                     = lookup(each.value.content, "gke_k8s_version", "") != "" ? lookup(each.value.content, "gke_k8s_version") : null
  gke_release_channel                 = lookup(each.value.content, "gke_release_channel", "") != "" ? lookup(each.value.content, "gke_release_channel") : null
  gke_name                            = lookup(each.value.content, "gke_name", "") != "" ? lookup(each.value.content, "gke_name") : null
  gke_isregional                      = lookup(each.value.content, "gke_isregional", "") != "" ? lookup(each.value.content, "gke_isregional") : null
  gke_zone                            = lookup(each.value.content, "gke_zone", "") != "" ? lookup(each.value.content, "gke_zone") : null
  gke_network                         = lookup(each.value.content, "gke_network", "") != "" ? lookup(each.value.content, "gke_network") : null
  gke_subnetwork                      = lookup(each.value.content, "gke_subnetwork", "") != "" ? lookup(each.value.content, "gke_subnetwork") : null
  gke_ip_range_pods                   = lookup(each.value.content, "gke_ip_range_pods", "") != "" ? lookup(each.value.content, "gke_ip_range_pods") : null
  gke_ip_range_services               = lookup(each.value.content, "gke_ip_range_services", "") != "" ? lookup(each.value.content, "gke_ip_range_services") : null
  gke_create_sa                       = lookup(each.value.content, "gke_create_sa", "") != "" ? lookup(each.value.content, "gke_create_sa") : null
  gke_default_max_pods_per_node       = lookup(each.value.content, "gke_default_max_pods_per_node", "") != "" ? lookup(each.value.content, "gke_default_max_pods_per_node") : null
  gke_remove_default_node_pool        = lookup(each.value.content, "gke_remove_default_node_pool", "") != "" ? lookup(each.value.content, "gke_remove_default_node_pool") : null
  gke_http_load_balancing             = lookup(each.value.content, "gke_http_load_balancing", "") != "" ? lookup(each.value.content, "gke_http_load_balancing") : null
  gke_network_policy                  = lookup(each.value.content, "gke_network_policy", "") != "" ? lookup(each.value.content, "gke_network_policy") : null
  gke_horizontal_pod_autoscaling      = lookup(each.value.content, "gke_horizontal_pod_autoscaling", "") != "" ? lookup(each.value.content, "gke_horizontal_pod_autoscaling") : null
  gke_filestore_csi_driver            = lookup(each.value.content, "gke_filestore_csi_driver", "") != "" ? lookup(each.value.content, "gke_filestore_csi_driver") : null
  gke_dns_cache                       = lookup(each.value.content, "gke_dns_cache", "") != "" ? lookup(each.value.content, "gke_dns_cache") : null
  gke_deletion_protection             = lookup(each.value.content, "gke_deletion_protection", "") != "" ? lookup(each.value.content, "gke_deletion_protection") : null
  gke_node_pools_settings             = lookup(each.value.content, "gke_node_pools_settings", "") != "" ? lookup(each.value.content, "gke_node_pools_settings") : null
  gke_node_pools_oauth_scopes_all     = lookup(each.value.content, "gke_node_pools_oauth_scopes_all", "") != "" ? lookup(each.value.content, "gke_node_pools_oauth_scopes_all") : null
  gke_node_pools_oauth_scopes_default = lookup(each.value.content, "gke_node_pools_oauth_scopes_default", "") != "" ? lookup(each.value.content, "gke_node_pools_oauth_scopes_default") : null
  gke_master_authorized_networks      = lookup(each.value.content, "gke_master_authorized_networks", "") != "" ? lookup(each.value.content, "gke_master_authorized_networks") : null

  depends_on = [module.gcp_apis_services, module.gcp_vpc_network]
}
