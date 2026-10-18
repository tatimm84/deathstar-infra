# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# OUTPUTS
# --------------------------------------------------------------------
output "ssl_certificate_id" {
  description = "Certificate manager ssl certificate id"
  value       = length(google_compute_ssl_certificate.ssl_certificate) > 0 ? google_compute_ssl_certificate.ssl_certificate[0].id : null
}
output "ssl_certificate_name" {
  description = "Certificate manager ssl certificate name"
  value       = length(google_compute_ssl_certificate.ssl_certificate) > 0 ? google_compute_ssl_certificate.ssl_certificate[0].name : null
}
output "ssl_certificate_self_link" {
  description = "Certificate manager ssl certificate self link"
  value       = length(google_compute_ssl_certificate.ssl_certificate) > 0 ? google_compute_ssl_certificate.ssl_certificate[0].self_link : null
}
output "ssl_policy_id" {
  description = "Netowrk services ssl policy id"
  value       = length(google_compute_ssl_policy.ssl_policy) > 0 ? google_compute_ssl_policy.ssl_policy[0].id : null
}
output "ssl_policy_name" {
  description = "Netowrk services ssl policy name"
  value       = length(google_compute_ssl_policy.ssl_policy) > 0 ? google_compute_ssl_policy.ssl_policy[0].name : null
}
output "ssl_policy_self_link" {
  description = "Netowrk services ssl policy self link"
  value       = length(google_compute_ssl_policy.ssl_policy) > 0 ? google_compute_ssl_policy.ssl_policy[0].self_link : null
}
output "armor_policy_id" {
  description = "Netowrk security cloud armor policy id"
  value       = length(google_compute_security_policy.armor) > 0 ? google_compute_security_policy.armor[0].id : null
}
output "armor_policy_name" {
  description = "Netowrk security cloud armor policy name"
  value       = length(google_compute_security_policy.armor) > 0 ? google_compute_security_policy.armor[0].name : null
}
output "armor_policy_self_link" {
  description = "Netowrk security cloud armor policy self link"
  value       = length(google_compute_security_policy.armor) > 0 ? google_compute_security_policy.armor[0].self_link : null
}
