# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# OUTPUTS
# --------------------------------------------------------------------
output "gke_cluster_id" {
  description = "GKE Cluster ID"
  value       = length(module.gke) > 0 ? module.gke.cluster_id : null
}

output "gke_endpoint" {
  description = "GKE Cluster ID"
  value       = length(module.gke) > 0 ? module.gke.endpoint : null
}

output "gke_name" {
  description = "GKE Cluster ID"
  value       = length(module.gke) > 0 ? module.gke.name : null
}
