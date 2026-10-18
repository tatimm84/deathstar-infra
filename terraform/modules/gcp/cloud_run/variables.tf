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
variable "RUNNING_SERVICE_ACCOUNT" {
  type        = string
  description = "Service Account used to run the resources"
  default     = null
}

# --------------------------------------------------------------------
# CLOUD RUN - SERVICE/JOB
# --------------------------------------------------------------------
variable "cloud_run_type" {
  type        = string
  description = "Cloud run type"
  default     = "service"
}
variable "name" {
  type        = string
  description = "Cloud run service/job name"
}
variable "annotations" {
  type        = map(string)
  description = "Cloud run service/job annotations"
  default     = null
}
variable "client" {
  type        = string
  description = "Cloud run service/job client"
  default     = null
}
variable "client_version" {
  type        = string
  description = "Cloud run service/job client version"
  default     = null
}
variable "custom_audiences" {
  type        = list(string)
  description = "Cloud run service/job custom audiences"
  default     = null
}
variable "description" {
  type        = string
  description = "Cloud run service/job description"
  default     = null
}
variable "ingress" {
  type        = string
  description = "Cloud run service/job ingress"
  default     = null
}
variable "labels" {
  type        = map(string)
  description = "Cloud run service/job labels"
  default     = null
}
variable "launch_stage" {
  type        = string
  description = "Cloud run service/job launch stage"
  default     = null
}
variable "binary_authorization" {
  description = "Cloud run service/job binary authorization"
  default     = null
}
variable "traffic" {
  description = "Cloud run service/job traffic"
  default     = null
}
variable "template" {
  description = "Cloud run service/job template"
  default     = null
}

# --------------------------------------------------------------------
# CLOUD RUN - SERVICES IAM
# --------------------------------------------------------------------
variable "iam_type" {
  type        = string
  description = "Cloud run service iam type"
  default     = "member"
}
variable "iam_member" {
  type        = string
  description = "Cloud run service iam member"
  default     = "allAuthenticatedUsers"
}
variable "iam_members" {
  type        = list(string)
  description = "Cloud run service iam members"
  default     = ["allAuthenticatedUsers"]
}
variable "iam_condition" {
  description = "Cloud run service iam condition"
  default     = []
}
