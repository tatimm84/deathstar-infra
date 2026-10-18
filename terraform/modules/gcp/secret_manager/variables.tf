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

# --------------------------------------------------------------------
# SECRET MANAGER - SECRET
# --------------------------------------------------------------------
variable "secret_create" {
  type        = bool
  description = "Secret manager secret create"
  default     = true
}
variable "secret_id" {
  type        = string
  description = "Secret manager secret id"
}
variable "annotations" {
  type        = map(string)
  description = "Secret manager secret annotations"
  default     = null
}
variable "expire_time" {
  type        = string
  description = "Secret manager secret expire time"
  default     = null
}
variable "labels" {
  type        = map(string)
  description = "Secret manager secret labels"
  default     = null
}
variable "ttl" {
  type        = string
  description = "Secret manager secret ttl"
  default     = null
}
variable "version_aliases" {
  type        = map(string)
  description = "Secret manager secret version aliases"
  default     = null
}
variable "replication" {
  description = "Secret manager secret replication"
  default     = null
}
variable "rotation" {
  description = "Secret manager secret rotation"
  default     = null
}
variable "topics" {
  description = "Secret manager secret topics"
  default     = null
}

# --------------------------------------------------------------------
# SECRET MANAGER - VERSION
# --------------------------------------------------------------------
variable "secret_path" {
  type        = string
  description = "Secret manager version secret path"
  default     = null
}
variable "secret_data" {
  type        = string
  description = "Secret manager version secret data"
  default     = null
}
variable "enabled" {
  type        = bool
  description = "Secret manager version enabled"
  default     = null
}
variable "deletion_policy" {
  type        = string
  description = "Secret manager version deletion policy"
  default     = null
}
variable "is_secret_data_base64" {
  type        = bool
  description = "Secret manager version is secret data base64"
  default     = null
}

# --------------------------------------------------------------------
# SECRET MANAGER - IAM MEMBER
# --------------------------------------------------------------------
variable "iam_members" {
  type        = set(string)
  description = "Secret manager IAM Members"
  default     = []
}


variable "iam_member_role" {
  type        = string
  description = "Secret manager IAM Role"
  default     = null
}
