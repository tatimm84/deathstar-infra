# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# Environment, UID_NOW
# --------------------------------------------------------------------
variable "ENVIRONMENT" {
  type        = string
  description = "GCP project Environment"
}
variable "UID_NOW" {
  type        = string
  description = "Datetime now in format YmdHMS"
  # default = formatdate("YYYYMMDDhhmm", timestamp())
}

# --------------------------------------------------------------------
# Resources Variables - Azure Devops
# --------------------------------------------------------------------
variable "AZURE_DEVOPS_REPO" {
  type        = string
  description = "Azure Devops repository name"
}
variable "SONARCLOUD_TOKEN" {
  type        = string
  description = "Sonarcloud service account token saved in variable groups"
  default     = null
}

# --------------------------------------------------------------------
# Resources Variables - CLOUD SQL
# --------------------------------------------------------------------
variable "SQL_USER_PW" {
  type        = string
  description = "Cloud SQL User Password"
  default     = null
}

# --------------------------------------------------------------------
# Resources Variables - GCP Project
# --------------------------------------------------------------------
variable "GCP_PROJECT" {
  type        = string
  description = "GCP project id"
}
variable "PROJECT_NUMBER" {
  type        = string
  description = "GCP project number"
}
variable "GCP_REGION" {
  type        = string
  description = "GCP region"
}

variable "RUNNING_SERVICE_ACCOUNT" {
  type        = string
  description = "Service Account used to run the resources"
  default     = null
}

# --------------------------------------------------------------------
# Resources Variables - Terraform
# --------------------------------------------------------------------
variable "SRC_CODE_PATH" {
  type        = string
  description = "Source code path"
  default     = "../src"
}
variable "SRC_DOCS_PATH" {
  type        = string
  description = "Source docs path"
  default     = "../docs"
}
variable "SRC_INFRA_PATH" {
  type        = string
  description = "Source infra path used at terraform resources"
  default     = "../infra"
}

locals {
  template_vars = {
    "ENVIRONMENT" : "${var.ENVIRONMENT}",
    "UID_NOW" : "${var.UID_NOW}",
    "GCP_PROJECT" : "${var.GCP_PROJECT}",
    "PROJECT_NUMBER" : "${var.PROJECT_NUMBER}",
    "GCP_REGION" : "${var.GCP_REGION}",
    "SRC_CODE_PATH" : "${var.SRC_CODE_PATH}",
    "SRC_DOCS_PATH" : "${var.SRC_DOCS_PATH}",
    "SRC_INFRA_PATH" : "${var.SRC_INFRA_PATH}",
    "RUNNING_SERVICE_ACCOUNT" : "${var.RUNNING_SERVICE_ACCOUNT}",
    "TOKEN_SA" : "${data.google_client_config.default.access_token}"
  }
}

# --------------------------------------------------------------------
# Data Lake Ingestion
# --------------------------------------------------------------------

variable "DLI_COMPOSER_BUCKET" {
  type        = string
  description = "Bucket using in Composer Datalake Ingestion"
  default     = ""
}

variable "DLI_COMPOSER_DAG_PATH" {
  type        = string
  description = "DAGs Path using in bucket Composer Datalake Ingestion"
  default     = ""
}

variable "DLI_DATAINTEGRATOR_BUCKET" {
  type        = string
  description = "Path using in bucket Dataintegrator Datalake Ingestion"
  default     = ""
}

variable "DLI_DATAINTEGRATOR_PATH" {
  type        = string
  description = "Path using in bucket Dataintegrator Datalake Ingestion"
  default     = ""
}
