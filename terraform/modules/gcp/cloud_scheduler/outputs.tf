# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# OUTPUTS
# --------------------------------------------------------------------
output "scheduler_id" {
  description = "Cloud scheduler id"
  value       = google_cloud_scheduler_job.job.id
}
output "scheduler_name" {
  description = "Cloud scheduler name"
  value       = google_cloud_scheduler_job.job.name
}
