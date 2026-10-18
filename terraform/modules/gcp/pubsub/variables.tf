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
  default     = "southamerica-east1"
}

# --------------------------------------------------------------------
# TOPIC
# --------------------------------------------------------------------

variable "topic_create" {
  type        = string
  description = "Bollean to create topic"
  default     = null
}

variable "topic_name" {
  type        = string
  description = "Topic Name"
  default     = null
}

variable "labels" {
  type        = map(string)
  description = "Topic Labels labels"
  default     = null
}

variable "kms_key_name" {
  type        = string
  description = "Topic KMS Key Name"
  default     = null
}

variable "message_retention_duration" {
  type        = string
  description = "Message Retention Duration"
  default     = null
}

# --------------------------------------------------------------------
# SUBSCRIPTION
# --------------------------------------------------------------------

variable "subscription_create" {
  type        = string
  description = "Bollean to create subscription"
  default     = null
}

variable "subscription_name" {
  type        = string
  description = "Subscription Name"
  default     = null
}

variable "filter" {
  type        = string
  description = "Filter Subscription"
  default     = null
}

variable "retain_acked_messages" {
  type        = bool
  description = "Retain Acked Messages"
  default     = null
}

variable "ack_deadline_seconds" {
  type        = number
  description = "Ack Deadline Seconds"
  default     = null
}

variable "push_config" {
  type        = any
  description = "Push Config"
  default     = null
}

variable "bigquery_config" {
  type        = any
  description = "BigQuery Config"
  default     = null
}

variable "dead_letter_policy" {
  type        = any
  description = "Dead Letter Policy"
  default     = null
}

variable "retry_policy" {
  type        = any
  description = "Retry Policy"
  default     = null
}

variable "expiration_policy" {
  type        = any
  description = "Expiration Policy"
  default     = null
}

variable "enable_message_ordering" {
  type        = bool
  description = "Enable Message Ordering"
  default     = null
}
