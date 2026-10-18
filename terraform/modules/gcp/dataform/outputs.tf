# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# OUTPUTS
# --------------------------------------------------------------------
output "repository_id" {
  description = "Dataform repository id"
  value       = length(google_dataform_repository.repository) > 0 ? google_dataform_repository.repository[0].id : null
}
output "repository_name" {
  description = "Dataform repository name"
  value       = length(google_dataform_repository.repository) > 0 ? google_dataform_repository.repository[0].name : null
}
output "release_config_id" {
  description = "Dataform release config id"
  value       = length(google_dataform_repository_release_config.release_config) > 0 ? google_dataform_repository_release_config.release_config[0].id : null
}
output "release_config_name" {
  description = "Dataform release config name"
  value       = length(google_dataform_repository_release_config.release_config) > 0 ? google_dataform_repository_release_config.release_config[0].name : null
}
output "workflow_config_ids" {
  description = "Map of Dataform workflow config ids, keyed by workflow name"
  value       = { for k, v in google_dataform_repository_workflow_config.workflow_config : k => v.id }
}
output "workflow_config_names" {
  description = "Map of Dataform workflow config names, keyed by workflow name"
  value       = { for k, v in google_dataform_repository_workflow_config.workflow_config : k => v.name }
}
