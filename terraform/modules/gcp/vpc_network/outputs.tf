# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# OUTPUTS
# --------------------------------------------------------------------
output "global_ip_id" {
  description = "VPC network global ip id"
  value       = length(google_compute_global_address.global_ip) > 0 ? google_compute_global_address.global_ip[0].id : null
}
output "global_ip_name" {
  description = "VPC network global ip name"
  value       = length(google_compute_global_address.global_ip) > 0 ? google_compute_global_address.global_ip[0].name : null
}
output "global_ip_self_link" {
  description = "VPC network global ip self link"
  value       = length(google_compute_global_address.global_ip) > 0 ? google_compute_global_address.global_ip[0].self_link : null
}
output "regional_ip_id" {
  description = "VPC network regional ip id"
  value       = length(google_compute_address.regional_ip) > 0 ? google_compute_address.regional_ip[0].id : null
}
output "regional_ip_name" {
  description = "VPC network regional ip name"
  value       = length(google_compute_address.regional_ip) > 0 ? google_compute_address.regional_ip[0].name : null
}
output "regional_ip_self_link" {
  description = "VPC network regional ip self link"
  value       = length(google_compute_address.regional_ip) > 0 ? google_compute_address.regional_ip[0].self_link : null
}
output "network_id" {
  description = "VPC network id"
  value       = length(google_compute_network.network) > 0 ? google_compute_network.network[0].id : null
}
output "network_name" {
  description = "VPC network name"
  value       = length(google_compute_network.network) > 0 ? google_compute_network.network[0].name : null
}
output "network_self_link" {
  description = "VPC network self link"
  value       = length(google_compute_network.network) > 0 ? google_compute_network.network[0].self_link : null
}
output "subnetwork_id" {
  description = "VPC network subnetwork id"
  value       = length(google_compute_subnetwork.subnetwork) > 0 ? google_compute_subnetwork.subnetwork[0].id : null
}
output "subnetwork_name" {
  description = "VPC network subnetwork name"
  value       = length(google_compute_subnetwork.subnetwork) > 0 ? google_compute_subnetwork.subnetwork[0].name : null
}
output "subnetwork_self_link" {
  description = "VPC network subnetwork self link"
  value       = length(google_compute_subnetwork.subnetwork) > 0 ? google_compute_subnetwork.subnetwork[0].self_link : null
}
output "firewall_id" {
  description = "VPC network firewall id"
  value       = length(google_compute_firewall.firewall) > 0 ? google_compute_firewall.firewall[0].id : null
}
output "firewall_name" {
  description = "VPC network firewall name"
  value       = length(google_compute_firewall.firewall) > 0 ? google_compute_firewall.firewall[0].name : null
}
output "firewall_self_link" {
  description = "VPC network firewall self link"
  value       = length(google_compute_firewall.firewall) > 0 ? google_compute_firewall.firewall[0].self_link : null
}
