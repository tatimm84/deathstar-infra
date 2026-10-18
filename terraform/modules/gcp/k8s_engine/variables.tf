# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# GCP PROJECT
# --------------------------------------------------------------------
variable "gcp_project" {
  type        = string
  description = "GCP project id"
}
variable "gcp_region" {
  type        = string
  description = "GCP region"
  default     = "southamerica-east1"
}

# --------------------------------------------------------------------
# GKE
# --------------------------------------------------------------------

variable "gke_k8s_version" {
  type        = string
  description = "GKE k8s Version"
  default     = null
}

variable "gke_release_channel" {
  type        = string
  description = "GKE Release Channel"
  default     = null
}

variable "gke_name" {
  type        = string
  description = "GKE Name"
  default     = null
}

variable "gke_isregional" {
  type        = bool
  description = "Is GKE Regional?"
  default     = true
}

variable "gke_zone" {
  description = "GKE Zones"
  default     = []
}

variable "gke_network" {
  type        = string
  description = "GKE Network"
  default     = null
}

variable "gke_subnetwork" {
  type        = string
  description = "GKE Subnetwork"
  default     = null
}

variable "gke_ip_range_pods" {
  type        = string
  description = "GKE IP Range Pods"
  default     = null
}

variable "gke_ip_range_services" {
  type        = string
  description = "GKE IP Range Services"
  default     = null
}

variable "gke_create_sa" {
  type        = bool
  description = "Create Service Account?"
  default     = false
}

variable "gke_http_load_balancing" {
  type        = bool
  description = "GKE HTTP Load Balancing"
  default     = null
}

variable "gke_network_policy" {
  type        = bool
  description = "GKE Network Policy"
  default     = null
}

variable "gke_horizontal_pod_autoscaling" {
  type        = bool
  description = "GKE Horizontal Pod Autoscaling"
  default     = null
}


variable "gke_filestore_csi_driver" {
  type        = bool
  description = "GKE Filestore CSI Driver"
  default     = null
}


variable "gke_dns_cache" {
  type        = bool
  description = "GKE DNS Cache"
  default     = null
}

variable "gke_deletion_protection" {
  type        = bool
  description = "GKE Deletion Protection"
  default     = true
}

variable "gke_default_max_pods_per_node" {
  type        = number
  description = "GKE Default Max Pods Per Node"
  default     = 100
}

variable "gke_remove_default_node_pool" {
  type        = bool
  description = "GKE Remove Default Node Pool"
  default     = false
}

variable "gke_node_pools_settings" {
  description = "GKE Node Pools Settings"
  default     = null
}

variable "gke_node_pools_oauth_scopes_all" {
  description = "GKE Node Pools OAuth Scopes - All"
  default     = null
}

variable "gke_node_pools_oauth_scopes_default" {
  description = "GKE Node Pools OAuth Scopes - Default"
  default     = null
}

variable "gke_master_authorized_networks" {
  description = "GKE Master Authorized Networks"
  default     = null
}
