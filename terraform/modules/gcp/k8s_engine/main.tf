# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# GKE Google Kubernetes Engine
# --------------------------------------------------------------------

# https://registry.terraform.io/modules/terraform-google-modules/kubernetes-engine/google/latest
module "gke" {
  source                     = "terraform-google-modules/kubernetes-engine/google"
  version                    = "34.0.0"
  kubernetes_version         = var.gke_k8s_version
  release_channel            = var.gke_release_channel
  project_id                 = var.gcp_project
  name                       = var.gke_name
  regional                   = var.gke_isregional
  region                     = var.gcp_region
  zones                      = var.gke_zone
  network                    = var.gke_network
  subnetwork                 = var.gke_subnetwork
  ip_range_pods              = var.gke_ip_range_pods
  ip_range_services          = var.gke_ip_range_services
  create_service_account     = var.gke_create_sa
  default_max_pods_per_node  = var.gke_default_max_pods_per_node
  remove_default_node_pool   = var.gke_remove_default_node_pool
  http_load_balancing        = var.gke_http_load_balancing
  network_policy             = var.gke_network_policy
  horizontal_pod_autoscaling = var.gke_horizontal_pod_autoscaling
  filestore_csi_driver       = var.gke_filestore_csi_driver
  dns_cache                  = var.gke_dns_cache
  deletion_protection        = var.gke_deletion_protection

  node_pools = distinct(flatten([
    for setting in var.gke_node_pools_settings : [{
      name                 = lookup(setting, "name", null)
      machine_type         = lookup(setting, "machine_type", null)
      min_count            = lookup(setting, "min_count", null)
      max_count            = lookup(setting, "max_count", null)
      local_ssd_count      = lookup(setting, "local_ssd_count", null)
      disk_size_gb         = lookup(setting, "disk_size_gb", null)
      disk_type            = lookup(setting, "disk_type", null)
      image_type           = lookup(setting, "image_type", null)
      auto_repair          = lookup(setting, "auto_repair", null)
      auto_upgrade         = lookup(setting, "auto_upgrade", null)
      preemptible          = lookup(setting, "preemptible", null)
      max_pods_per_node    = lookup(setting, "max_pods_per_node", null)
      service_account      = lookup(setting, "service_account", null)
      enable_gcfs          = lookup(setting, "enable_gcfs", false)
      enable_gvnic         = lookup(setting, "enable_gvnic", false)
      pod_range            = lookup(setting, "pod_range", null)
      enable_private_nodes = lookup(setting, "enable_private_nodes", true)
    }]
  ]))

  node_pools_oauth_scopes = {
    all               = var.gke_node_pools_oauth_scopes_all
    default-node-pool = var.gke_node_pools_oauth_scopes_default
  }

  master_authorized_networks = distinct(flatten([
    for master_authorized in var.gke_master_authorized_networks : [{
      cidr_block   = lookup(master_authorized, "cidr_block", null)
      display_name = lookup(master_authorized, "display_name", null)
    }]
  ]))

  depends_on = []
}
