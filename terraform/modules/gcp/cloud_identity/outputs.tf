# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# OUTPUTS
# --------------------------------------------------------------------
output "identity_group_id" {
  description = "Cloud identity group id"
  value       = length(google_cloud_identity_group.id_group) > 0 ? google_cloud_identity_group.id_group[0].id : null
}
output "identity_group_name" {
  description = "Cloud identity group name"
  value       = length(google_cloud_identity_group.id_group) > 0 ? google_cloud_identity_group.id_group[0].name : null
}
output "identity_group_membership_id" {
  description = "Cloud identity group membership id"
  value       = length(google_cloud_identity_group_membership.id_group_membership) > 0 ? google_cloud_identity_group_membership.id_group_membership[0].id : null
}
output "identity_group_membership_name" {
  description = "Cloud identity group membership name"
  value       = length(google_cloud_identity_group_membership.id_group_membership) > 0 ? google_cloud_identity_group_membership.id_group_membership[0].name : null
}
