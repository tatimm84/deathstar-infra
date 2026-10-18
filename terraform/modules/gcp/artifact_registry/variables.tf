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
# ARTIFACT REGISTRY - REPOSITORY
# --------------------------------------------------------------------
variable "repository_create" {
  type        = bool
  description = "Artifact registry repository create"
  default     = true
}
variable "repository_id" {
  type        = string
  description = "Artifact registry repository id"
  default     = null
}
variable "format" {
  type        = string
  description = "Artifact registry repository format"
  default     = null
}
variable "cleanup_policy_dry_run" {
  type        = bool
  description = "Artifact registry repository cleanup policy dry run"
  default     = null
}
variable "description" {
  type        = string
  description = "Artifact registry repository description"
  default     = null
}
variable "kms_key_name" {
  type        = string
  description = "Artifact registry repository kms key name"
  default     = null
}
variable "mode" {
  type        = string
  description = "Artifact registry repository mode"
  default     = null
}
variable "cleanup_policies" {
  description = "Artifact registry repository cleanup policies"
  default     = null
}
variable "docker_config" {
  description = "Artifact registry repository docker config"
  default     = null
}
variable "maven_config" {
  description = "Artifact registry repository maven config"
  default     = null
}
variable "remote_repository_config" {
  description = "Artifact registry repository remote repository config"
  default     = null
}
variable "virtual_repository_config" {
  description = "Artifact registry repository virtual repository config"
  default     = null
}

# --------------------------------------------------------------------
# ARTIFACT REGISTRY - IMAGE - DOCKER_IMAGE
# --------------------------------------------------------------------
variable "image_name" {
  type        = string
  description = "Artifact registry image name"
  default     = null
}
variable "image_path" {
  type        = string
  description = "Artifact registry image src code path"
  default     = null
}

variable "login_regions" {
  type        = set(string)
  description = "Artifact registry image login regions"
  default     = []
}

variable "triggers" {
  type        = map(string)
  description = "Artifact registry image triggers"
  default     = null
}
variable "build" {
  description = "Artifact registry image build"
  default     = null
}
variable "build_args_default" {
  description = "Artifact registry image build args default"
  default     = {}
}
variable "context" {
  description = "Artifact registry image context"
  default     = null
}
variable "sha1_json" {
  description = "Artifact registry image json config"
  default     = null
}
variable "tag_treated" {
  type        = set(string)
  description = "Artifact registry image tag treated"
  default     = []
}
