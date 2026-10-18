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
# CLOUD FUNCTIONS - GENERATE .ZIP FILE
# --------------------------------------------------------------------
variable "source_dir" {
  type        = string
  description = "Archive file source dir"
}

# --------------------------------------------------------------------
# CLOUD FUNCTIONS - STORE .ZIP FILE
# --------------------------------------------------------------------
variable "bucket" {
  type        = string
  description = "Cloud storage bucket name"
}
variable "object_prefix" {
  type        = string
  description = "Cloud storage object prefix"
}

# --------------------------------------------------------------------
# CLOUD FUNCTIONS - CREATE FUNCTION
# --------------------------------------------------------------------
variable "generation" {
  type        = number
  description = "Cloud function generation"
  default     = 1
}
variable "name" {
  type        = string
  description = "Cloud function name"
}
variable "runtime" {
  type        = string
  description = "Cloud function runtime"
}
variable "available_memory_mb" {
  type        = number
  description = "Cloud function available memory in mb"
  default     = null
}
variable "build_worker_pool" {
  type        = string
  description = "Cloud function build worker pool"
  default     = null
}
variable "description" {
  type        = string
  description = "Cloud function description"
  default     = null
}
variable "docker_registry" {
  type        = string
  description = "Cloud function docker registry"
  default     = null
}
variable "docker_repository" {
  type        = string
  description = "Cloud function docker repository"
  default     = null
}
variable "entry_point" {
  type        = string
  description = "Cloud function entry point"
  default     = null
}
variable "environment_variables" {
  type        = map(string)
  description = "Cloud function environment variables"
  default     = null
}
variable "https_trigger_security_level" {
  type        = string
  description = "Cloud function https trigger security level"
  default     = null #"SECURE_ALWAYS"
}
variable "ingress_settings" {
  type        = string
  description = "Cloud function ingress settings"
  default     = null
}
variable "kms_key_name" {
  type        = string
  description = "Cloud function kms key name"
  default     = null
}
variable "labels" {
  type        = map(string)
  description = "Cloud function labels"
  default     = null
}
variable "max_instances" {
  type        = number
  description = "Cloud function max instances"
  default     = null
}
variable "min_instances" {
  type        = number
  description = "Cloud function min instances"
  default     = null
}
variable "service_account_email" {
  type        = string
  description = "Cloud function service account email"
  default     = null
}
variable "timeout" {
  type        = number
  description = "Cloud function timeout"
  default     = null
}
variable "trigger_http" {
  type        = bool
  description = "Cloud function trigger http"
  default     = null
}
variable "vpc_connector" {
  type        = string
  description = "Cloud function vpc connector"
  default     = null
}
variable "vpc_connector_egress_settings" {
  type        = string
  description = "Cloud function vpc connector egress settings"
  default     = null
}
variable "build_config" {
  description = "Cloud functions build config"
  default     = []
}
variable "event_trigger" {
  description = "Cloud functions event trigger"
  default     = []
}
variable "secret_environment_variables" {
  description = "Cloud functions secret environment variables"
  default     = []
}
variable "secret_volumes" {
  description = "Cloud functions secret volumes"
  default     = []
}
variable "service_config" {
  description = "Cloud functions service config"
  default     = []
}
variable "source_repository" {
  description = "Cloud functions source repository"
  default     = []
}

variable "template_vars" {
  description = "Cloud functions template_vars"
  default     = {}
}

variable "file_replace_regex" {
  description = "Cloud functions file replace regex"
  default     = null
}

# --------------------------------------------------------------------
# CLOUD RUN - SERVICES IAM
# --------------------------------------------------------------------
variable "iam_member" {
  type        = string
  description = "Cloud function iam member"
  default     = null
}
