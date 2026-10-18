# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# CLOUD TASKS - QUEUE
# --------------------------------------------------------------------
resource "google_cloud_tasks_queue" "queue" {
  count    = var.queue_create ? 1 : 0
  project  = var.gcp_project
  location = var.gcp_region
  name     = var.queue_name

  dynamic "rate_limits" {
    for_each = var.rate_limits
    content {
      max_dispatches_per_second = lookup(rate_limits.value, "max_dispatches_per_second", null)
      max_concurrent_dispatches = lookup(rate_limits.value, "max_concurrent_dispatches", null)
    }
  }

  dynamic "retry_config" {
    for_each = var.retry_config
    content {
      max_attempts       = lookup(retry_config.value, "max_attempts", null)
      max_retry_duration = lookup(retry_config.value, "max_retry_duration", null)
      max_backoff        = lookup(retry_config.value, "max_backoff", null)
      min_backoff        = lookup(retry_config.value, "min_backoff", null)
      max_doublings      = lookup(retry_config.value, "max_doublings", null)
    }
  }

  dynamic "stackdriver_logging_config" {
    for_each = var.stackdriver_logging_config
    content {
      sampling_ratio = lookup(stackdriver_logging_config.value, "sampling_ratio", null)
    }
  }
}

# --------------------------------------------------------------------
# CLOUD TASKS - IAM
# --------------------------------------------------------------------
resource "google_cloud_tasks_queue_iam_member" "queue_iam" {
  count    = length(var.iam_members) > 0 ? length(var.iam_members) : 0
  project  = var.gcp_project
  location = var.gcp_region
  name     = var.queue_name
  role     = var.iam_member_role
  member   = var.iam_members[count.index]

  depends_on = [google_cloud_tasks_queue.queue]
}
