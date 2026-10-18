# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# OUTPUTS
# --------------------------------------------------------------------
output "repository_id" {
  description = "Artifact registry repository id"
  value       = length(google_artifact_registry_repository.repo) > 0 ? google_artifact_registry_repository.repo[0].id : null
}
output "repository_name" {
  description = "Artifact registry repository name"
  value       = length(google_artifact_registry_repository.repo) > 0 ? google_artifact_registry_repository.repo[0].name : null
}
