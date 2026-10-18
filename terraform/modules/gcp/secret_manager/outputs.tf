# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# OUTPUTS
# --------------------------------------------------------------------
output "secret_id" {
  description = "Secret manager secret id"
  value       = length(google_secret_manager_secret.secret) > 0 ? google_secret_manager_secret.secret[0].id : null
}
output "secret_name" {
  description = "Secret manager secret name"
  value       = length(google_secret_manager_secret.secret) > 0 ? google_secret_manager_secret.secret[0].name : null
}
output "version_id" {
  description = "Secret manager version id"
  value       = length(google_secret_manager_secret_version.version) > 0 ? google_secret_manager_secret_version.version[0].id : null
}
output "version_name" {
  description = "Secret manager version name"
  value       = length(google_secret_manager_secret_version.version) > 0 ? google_secret_manager_secret_version.version[0].name : null
}
