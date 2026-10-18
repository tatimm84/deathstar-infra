# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# GCP PROJECT
# --------------------------------------------------------------------
variable "gcp_project" {
  type        = string
  description = "GCP project id"
}

variable "gcp_region" {
  type        = string
  description = "GCP region"
  default     = "us-central1"
}

# --------------------------------------------------------------------
# CLOUD TASKS - QUEUE
# --------------------------------------------------------------------
variable "queue_create" {
  type        = bool
  description = "Cloud tasks queue create"
  default     = true
}

variable "queue_name" {
  type        = string
  description = "Cloud tasks queue name"
}

variable "rate_limits" {
  description = "Cloud tasks queue rate limits configuration"
  type = list(object({
    max_dispatches_per_second = optional(number)
    max_concurrent_dispatches = optional(number)
  }))
  default = []
}

variable "retry_config" {
  description = "Cloud tasks queue retry configuration"
  type = list(object({
    max_attempts       = optional(number)
    max_retry_duration = optional(string)
    max_backoff        = optional(string)
    min_backoff        = optional(string)
    max_doublings      = optional(number)
  }))
  default = []
}

variable "stackdriver_logging_config" {
  description = "Cloud tasks queue Stackdriver logging configuration"
  type = list(object({
    sampling_ratio = optional(number)
  }))
  default = []
}

# --------------------------------------------------------------------
# CLOUD TASKS - IAM
# --------------------------------------------------------------------
variable "iam_members" {
  type        = list(string)
  description = "Cloud tasks queue iam members"
  default     = []
}

variable "iam_member_role" {
  type        = string
  description = "Cloud tasks queue iam member role"
  default     = "roles/cloudtasks.enqueuer"
}
