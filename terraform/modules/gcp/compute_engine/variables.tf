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
variable "gcp_zone" {
  type        = string
  description = "GCP region"
  default     = "southamerica-east1-b"
}

# --------------------------------------------------------------------
# COMPUTE ENGINE - INSTANCE
# --------------------------------------------------------------------
variable "name" {
  type        = string
  description = "Compute engine instance name"
  default     = null
}
variable "machine_type" {
  type        = string
  description = "Compute engine instance machine type"
  default     = null
}
variable "allow_stopping_for_update" {
  type        = bool
  description = "Compute engine instance allow stopping for update"
  default     = null
}
variable "deletion_protection" {
  type        = bool
  description = "Compute engine instance deletion protection"
  default     = null
}
variable "description" {
  type        = string
  description = "Compute engine instance description"
  default     = null
}
variable "desired_status" {
  type        = string
  description = "Compute engine instance desired status"
  default     = null
}
variable "enable_display" {
  type        = bool
  description = "Compute engine instance enable display"
  default     = null
}
variable "hostname" {
  type        = string
  description = "Compute engine instance hostname"
  default     = null
}
variable "labels" {
  type        = map(string)
  description = "Compute engine instance labels"
  default     = null
}
variable "metadata" {
  type        = map(string)
  description = "Compute engine instance metadata"
  default     = null
}
variable "metadata_startup_script" {
  type        = string
  description = "Compute engine instance metadata startup script"
  default     = null
}
variable "min_cpu_platform" {
  type        = string
  description = "Compute engine instance min cpu platform"
  default     = null
}
variable "resource_policies" {
  type        = list(string)
  description = "Compute engine instance resource policies"
  default     = null
}
variable "tags" {
  type        = list(string)
  description = "Compute engine instance tags"
  default     = null
}
variable "boot_disk" {
  description = "Compute engine instance boot disk"
  default     = null
}
variable "scratch_disk" {
  description = "Compute engine instance scratch disk"
  default     = null
}
variable "attached_disk" {
  description = "Compute engine instance attached disk"
  default     = null
}
variable "network_interface" {
  description = "Compute engine instance network interface"
  default     = null
}
variable "service_account" {
  description = "Compute engine instance service account"
  default     = null
}
variable "scheduling" {
  description = "Compute engine instance scheduling"
  default     = null
}
variable "guest_accelerator" {
  description = "Compute engine instance guest accelerator"
  default     = null
}
variable "shielded_instance_config" {
  description = "Compute engine instance shielded instance config"
  default     = null
}
variable "confidential_instance_config" {
  description = "Compute engine instance confidential instance config"
  default     = null
}
variable "advanced_machine_features" {
  description = "Compute engine instance advanced machine features"
  default     = null
}
variable "reservation_affinity" {
  description = "Compute engine instance reservation affinity"
  default     = null
}

# --------------------------------------------------------------------
# COMPUTE ENGINE - SCHEDULE POLICY
# --------------------------------------------------------------------
variable "instance_schedule_name" {
  type        = string
  description = "instance schedule name"
  default     = null
}
variable "schedule_description" {
  type        = string
  description = "Compute engine instance schedule description"
  default     = null
}
variable "snapshot_schedule_policy" {
  description = "Compute engine instance snapshot schedule policy"
  default     = null
}
variable "group_placement_policy" {
  description = "Compute engine instance group placement policy"
  default     = null
}
variable "instance_schedule_policy" {
  description = "Compute engine instance schedule policy"
  default     = null
}
variable "attach_schedule" {
  type        = bool
  description = "Compute engine instance attach scheduler policy"
  default     = null
}

# --------------------------------------------------------------------
# COMPUTE ENGINE - IAP TUNNEL INSTANCE IAM
# --------------------------------------------------------------------
variable "iam_type" {
  type        = string
  description = "Compute engine instance iam type"
  default     = "member"
}
variable "iam_member" {
  type        = string
  description = "Compute engine instance iam member"
  default     = "allAuthenticatedUsers"
}
variable "iam_members" {
  type        = list(string)
  description = "Compute engine instance iam members"
  default     = ["allAuthenticatedUsers"]
}
variable "iam_condition" {
  description = "Compute engine instance iam condition"
  default     = null
}
