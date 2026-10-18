# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# OUTPUTS
# --------------------------------------------------------------------
output "workflow_id" {
  description = "Workflow id"
  value       = google_workflows_workflow.workflow.id
}
output "workflow_name" {
  description = "Workflow name"
  value       = google_workflows_workflow.workflow.name
}
