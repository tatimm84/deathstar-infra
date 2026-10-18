# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# OUTPUTS
# --------------------------------------------------------------------
output "queue_id" {
  description = "Cloud tasks queue id"
  value       = length(google_cloud_tasks_queue.queue) > 0 ? google_cloud_tasks_queue.queue[0].id : null
}

output "queue_name" {
  description = "Cloud tasks queue name"
  value       = length(google_cloud_tasks_queue.queue) > 0 ? google_cloud_tasks_queue.queue[0].name : null
}

output "queue_location" {
  description = "Cloud tasks queue location"
  value       = length(google_cloud_tasks_queue.queue) > 0 ? google_cloud_tasks_queue.queue[0].location : null
}

output "queue_project" {
  description = "Cloud tasks queue project"
  value       = length(google_cloud_tasks_queue.queue) > 0 ? google_cloud_tasks_queue.queue[0].project : null
}
