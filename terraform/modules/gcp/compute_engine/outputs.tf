# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# OUTPUTS
# --------------------------------------------------------------------
output "instance_id" {
  description = "Compute engine instance id"
  value       = length(google_compute_instance.instance) > 0 ? google_compute_instance.instance[0].id : null
}
output "instance_name" {
  description = "Compute engine instance name"
  value       = length(google_compute_instance.instance) > 0 ? google_compute_instance.instance[0].name : null
}
output "instance_self_link" {
  description = "Compute engine instance self link"
  value       = length(google_compute_instance.instance) > 0 ? google_compute_instance.instance[0].self_link : null
}
output "backup_id" {
  description = "Compute engine instance backup id"
  value       = length(google_compute_resource_policy.resource_policy) > 0 ? google_compute_resource_policy.resource_policy[0].id : null
}
output "backup_name" {
  description = "Compute engine instance backup name"
  value       = length(google_compute_resource_policy.resource_policy) > 0 ? google_compute_resource_policy.resource_policy[0].name : null
}
output "backup_self_link" {
  description = "Compute engine instance backup self link"
  value       = length(google_compute_resource_policy.resource_policy) > 0 ? google_compute_resource_policy.resource_policy[0].self_link : null
}
