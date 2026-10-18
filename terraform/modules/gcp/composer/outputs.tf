# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# OUTPUTS
# --------------------------------------------------------------------
output "composer_1_id" {
  description = "Composer version 1 id"
  value       = length(google_composer_environment.composer_1) > 0 ? google_composer_environment.composer_1[0].id : null
}
output "composer_1_name" {
  description = "Composer version 1 name"
  value       = length(google_composer_environment.composer_1) > 0 ? google_composer_environment.composer_1[0].name : null
}
output "composer_2_id" {
  description = "Composer version 2 id"
  value       = length(google_composer_environment.composer_2) > 0 ? google_composer_environment.composer_2[0].id : null
}
output "composer_2_name" {
  description = "Composer version 2 name"
  value       = length(google_composer_environment.composer_2) > 0 ? google_composer_environment.composer_2[0].name : null
}
output "composer_3_id" {
  description = "Composer version 3 id"
  value       = length(google_composer_environment.composer_3) > 0 ? google_composer_environment.composer_3[0].id : null
}
output "composer_3_name" {
  description = "Composer version 3 name"
  value       = length(google_composer_environment.composer_3) > 0 ? google_composer_environment.composer_3[0].name : null
}
