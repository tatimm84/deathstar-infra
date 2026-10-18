# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# GCP PROJECT
# --------------------------------------------------------------------
variable "gcp_project" {
  type        = string
  description = "GCP project id"
  default     = null
}
variable "gcp_region" {
  type        = string
  description = "GCP region"
  default     = "us-central1"
}

# --------------------------------------------------------------------
# CLOUD STORAGE - BUCKET
# --------------------------------------------------------------------
variable "bucket_create" {
  type        = bool
  description = "Cloud storage bucket create"
  default     = true
}
variable "bucket" {
  type        = string
  description = "Cloud storage bucket"
}
variable "default_event_based_hold" {
  type        = bool
  description = "Cloud storage bucket default event based hold"
  default     = null
}
variable "enable_object_retention" {
  type        = bool
  description = "Cloud storage bucket enable object retention"
  default     = null
}
variable "force_destroy" {
  type        = bool
  description = "Cloud storage bucket force destroy"
  default     = null
}
variable "labels" {
  type        = map(string)
  description = "Cloud storage bucket labels"
  default     = null
}
variable "public_access_prevention" {
  type        = string
  description = "Cloud storage bucket public access prevention"
  default     = null
}
variable "requester_pays" {
  type        = bool
  description = "Cloud storage bucket requester pays"
  default     = null
}
variable "rpo" {
  type        = string
  description = "Cloud storage bucket rpo"
  default     = null
}
variable "storage_class_bucket" {
  type        = string
  description = "Cloud storage bucket storage class"
  default     = null
}
variable "uniform_bucket_level_access" {
  type        = bool
  description = "Cloud storage bucket uniform bucket level access"
  default     = null
}
variable "autoclass" {
  description = "Cloud storage bucket autoclass"
  default     = []
}
variable "cors" {
  description = "Cloud storage bucket cors"
  default     = []
}
variable "custom_placement_config" {
  description = "Cloud storage bucket custom placement config"
  default     = []
}
variable "encryption" {
  description = "Cloud storage bucket encryption"
  default     = []
}
variable "lifecycle_rule" {
  description = "Cloud storage bucket lifecycle rule"
  default     = []
}
variable "logging" {
  description = "Cloud storage bucket logging"
  default     = []
}
variable "retention_policy" {
  description = "Cloud storage bucket retention policy"
  default     = []
}
variable "soft_delete_policy" {
  description = "Cloud storage bucket soft delete policy"
  default     = []
}
variable "versioning" {
  description = "Cloud storage bucket versioning"
  default     = []
}
variable "website" {
  description = "Cloud storage bucket website"
  default     = []
}

# --------------------------------------------------------------------
# CLOUD STORAGE - OBJECT
# --------------------------------------------------------------------
variable "object_create" {
  type        = bool
  description = "Cloud storage object create"
  default     = true
}
variable "name" {
  type        = string
  description = "Cloud storage object name"
  default     = null
}
variable "content" {
  type        = string
  description = "Cloud storage object content"
  default     = null
}
variable "object_source" {
  type        = string
  description = "Cloud storage object source"
  default     = null
}
variable "metadata" {
  type        = map(string)
  description = "Cloud storage object metadata"
  default     = null
}
variable "cache_control" {
  type        = string
  description = "Cloud storage object cache control"
  default     = null
}
variable "content_disposition" {
  type        = string
  description = "Cloud storage object content disposition"
  default     = null
}
variable "content_encoding" {
  type        = string
  description = "Cloud storage object content encoding"
  default     = null
}
variable "content_language" {
  type        = string
  description = "Cloud storage object content language"
  default     = null
}
variable "content_type" {
  type        = string
  description = "Cloud storage object content type"
  default     = null
}
variable "detect_md5hash" {
  type        = string
  description = "Cloud storage object detect md5hash"
  default     = null
}
variable "event_based_hold" {
  type        = bool
  description = "Cloud storage object event based hold"
  default     = null
}
variable "kms_key_name" {
  type        = string
  description = "Cloud storage object kms key name"
  default     = null
}
variable "object_storage_class" {
  type        = string
  description = "Cloud storage object storage class"
  default     = null
}
variable "temporary_hold" {
  type        = bool
  description = "Cloud storage object temporary hold"
  default     = null
}
variable "customer_encryption" {
  description = "Cloud storage object customer encryption"
  default     = []
}
variable "retention" {
  description = "Cloud storage object retention"
  default     = []
}

# --------------------------------------------------------------------
# CLOUD STORAGE - ACL
# --------------------------------------------------------------------
variable "acl_role" {
  type        = string
  description = "Cloud storage ACL role"
  default     = null
}

variable "acl_entity" {
  type        = string
  description = "Cloud storage ACL entity"
  default     = null
}
