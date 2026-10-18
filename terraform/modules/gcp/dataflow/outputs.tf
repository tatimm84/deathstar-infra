# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# OUTPUTS
# --------------------------------------------------------------------
output "dataflow_job_id" {
  description = "Dataflow job id"
  value       = length(google_dataflow_job.job) > 0 ? google_dataflow_job.job[0].id : null
}
output "dataflow_job_type" {
  description = "Dataflow job type"
  value       = length(google_dataflow_job.job) > 0 ? google_dataflow_job.job[0].type : null
}
output "dataflow_job_state" {
  description = "Dataflow job state"
  value       = length(google_dataflow_job.job) > 0 ? google_dataflow_job.job[0].state : null
}
