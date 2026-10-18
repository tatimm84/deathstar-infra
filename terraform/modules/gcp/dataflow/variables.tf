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
variable "gcp_zone" {
  type        = string
  description = "GCP zone"
  default     = "us-central1-c"
}

# --------------------------------------------------------------------
# DATAFLOW - JOB
# --------------------------------------------------------------------
variable "name" {
  type        = string
  description = "Dataflow job name"
}
variable "template_gcs_path" {
  type        = string
  description = "GCS path to the Dataflow job template"
}
variable "temp_gcs_region" {
  type        = string
  description = "GCS region for the Dataflow job to dump its temporary data"
}
variable "parameters" {
  type        = map(string)
  description = "Dataflow job parameters"
  default     = null
}
variable "labels" {
  type        = map(string)
  description = "Dataflow job labels"
  default     = null
}
variable "transform_name_mapping" {
  type        = map(string)
  description = "Dataflow job transform name mapping"
  default     = null
}
variable "max_workers" {
  type        = number
  description = "Dataflow job max workers"
  default     = null
}
variable "on_delete" {
  type        = string
  description = "Dataflow job on delete behavior"
  default     = null
}
variable "skip_wait_on_job_termination" {
  type        = bool
  description = "Dataflow job skip wait on job termination"
  default     = null
}
variable "service_account_email" {
  type        = string
  description = "Dataflow job service account email"
  default     = null
}
variable "network" {
  type        = string
  description = "Dataflow job network"
  default     = null
}
variable "subnetwork" {
  type        = string
  description = "Dataflow job subnetwork"
  default     = null
}
variable "machine_type" {
  type        = string
  description = "Dataflow job machine type"
  default     = null
}
variable "kms_key_name" {
  type        = string
  description = "Dataflow job kms key name"
  default     = null
}
variable "ip_configuration" {
  type        = string
  description = "Dataflow job ip configuration"
  default     = null
}
variable "additional_experiments" {
  type        = set(string)
  description = "Dataflow job additional experiments"
  default     = null
}
variable "enable_streaming_engine" {
  type        = bool
  description = "Dataflow job enable streaming engine"
  default     = null
}
