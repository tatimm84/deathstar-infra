# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# CLOUD IDENTITY - GROUP
# --------------------------------------------------------------------
variable "parent" {
  type        = string
  description = "Cloud identity group parent"
  default     = null
}
variable "display_name" {
  type        = string
  description = "Cloud identity group display name"
  default     = null
}
variable "description" {
  type        = string
  description = "Cloud identity group description"
  default     = null
}
variable "initial_group_config" {
  type        = string
  description = "Cloud identity group initial group config"
  default     = null
}
variable "labels" {
  type        = map(string)
  description = "Cloud identity group labels"
  default     = null
}
variable "group_key" {
  description = "Cloud identity group group key"
  default     = null
}

# --------------------------------------------------------------------
# CLOUD IDENTITY - GROUP MEMBERSHIP
# --------------------------------------------------------------------
variable "group" {
  type        = string
  description = "Cloud identity group membership group"
  default     = null
}
variable "member_key" {
  description = "Cloud identity group membership member key"
  default     = null
}
variable "preferred_member_key" {
  description = "Cloud identity group membership preferred member key"
  default     = null
}
variable "roles" {
  description = "Cloud identity group membership roles"
  default     = null
}
