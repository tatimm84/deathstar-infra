# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# OUTPUTS
# --------------------------------------------------------------------
output "run_service_id" {
  description = "Cloud run service id"
  value       = length(google_cloud_run_v2_service.service) > 0 ? google_cloud_run_v2_service.service[0].id : null
}
output "run_service_name" {
  description = "Cloud run service name"
  value       = length(google_cloud_run_v2_service.service) > 0 ? google_cloud_run_v2_service.service[0].name : null
}
output "run_service_uri" {
  description = "Cloud run service uri"
  value       = length(google_cloud_run_v2_service.service) > 0 ? google_cloud_run_v2_service.service[0].uri : null
}
output "run_job_id" {
  description = "Cloud run job id"
  value       = length(google_cloud_run_v2_job.job) > 0 ? google_cloud_run_v2_job.job[0].id : null
}
output "run_job_name" {
  description = "Cloud run job name"
  value       = length(google_cloud_run_v2_job.job) > 0 ? google_cloud_run_v2_job.job[0].name : null
}
