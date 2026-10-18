# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# PubSub
# --------------------------------------------------------------------
locals {
  topic        = module.json_topic_reader.parsed_data
  subscription = module.json_subscription_reader.parsed_data
}

module "json_topic_reader" {
  source = "./modules/utils/reader"

  source_path = "${var.SRC_INFRA_PATH}/gcp/auto/pubsub/"
  enviroment  = var.ENVIRONMENT
  files_regex = "*"
  template_vars = {
    "__project_number__" = var.PROJECT_NUMBER,
    "__project_name__"   = var.GCP_PROJECT,
    "__region__"         = var.GCP_REGION,
    "__env__"            = var.ENVIRONMENT,
    "__uid_now__"        = var.UID_NOW
  }
}

module "json_subscription_reader" {
  source = "./modules/utils/reader"

  source_path = "${var.SRC_INFRA_PATH}/gcp/auto/pubsub/"
  enviroment  = var.ENVIRONMENT
  files_regex = "[^.]**/[^.]*.json"
  template_vars = {
    "__project_number__" = var.PROJECT_NUMBER,
    "__project_name__"   = var.GCP_PROJECT,
    "__region__"         = var.GCP_REGION,
    "__env__"            = var.ENVIRONMENT,
    "__uid_now__"        = var.UID_NOW
  }
}

module "topic" {
  for_each                   = { for entry in local.topic : "${entry.source}" => entry }
  source                     = "./modules/gcp/pubsub"
  gcp_project                = var.GCP_PROJECT
  topic_create               = true
  subscription_create        = false
  topic_name                 = lookup(each.value.content, "topic_name", "") != "" ? lookup(each.value.content, "topic_name") : "${each.value.file_name}"
  labels                     = lookup(each.value.content, "labels", {}) != {} ? lookup(each.value.content, "labels") : null
  kms_key_name               = lookup(each.value.content, "kms_key_name", "") != "" ? lookup(each.value.content, "kms_key_name") : null
  message_retention_duration = lookup(each.value.content, "message_retention_duration", "") != "" ? lookup(each.value.content, "message_retention_duration") : null

}

module "subscription" {
  for_each                   = { for entry in local.subscription : "${entry.source}" => entry }
  source                     = "./modules/gcp/pubsub"
  gcp_project                = var.GCP_PROJECT
  topic_create               = false
  subscription_create        = true
  topic_name                 = lookup(each.value.content, "topic_name", "") != "" ? lookup(each.value.content, "topic_name") : "${each.value.path_name}"
  subscription_name          = lookup(each.value.content, "subscription_name", "") != "" ? lookup(each.value.content, "subscription_name") : "${each.value.file_name}"
  labels                     = lookup(each.value.content, "labels", {}) != {} ? lookup(each.value.content, "labels") : null
  filter                     = lookup(each.value.content, "filter", "") != "" ? lookup(each.value.content, "filter") : null
  message_retention_duration = lookup(each.value.content, "message_retention_duration", "") != "" ? lookup(each.value.content, "message_retention_duration") : null
  retain_acked_messages      = lookup(each.value.content, "retain_acked_messages", "") != "" ? lookup(each.value.content, "retain_acked_messages") : null
  ack_deadline_seconds       = lookup(each.value.content, "ack_deadline_seconds", "") != "" ? lookup(each.value.content, "ack_deadline_seconds") : null
  push_config                = lookup(each.value.content, "push_config", "") != "" ? [lookup(each.value.content, "push_config")] : []
  bigquery_config            = lookup(each.value.content, "bigquery_config", "") != "" ? [lookup(each.value.content, "bigquery_config")] : []
  dead_letter_policy         = lookup(each.value.content, "dead_letter_policy", "") != "" ? [lookup(each.value.content, "dead_letter_policy")] : []
  retry_policy               = lookup(each.value.content, "retry_policy", "") != "" ? [lookup(each.value.content, "retry_policy")] : []
  expiration_policy          = lookup(each.value.content, "expiration_policy", "") != "" ? [lookup(each.value.content, "expiration_policy")] : []
  enable_message_ordering    = lookup(each.value.content, "enable_message_ordering", "") != "" ? lookup(each.value.content, "enable_message_ordering") : null

  depends_on = [module.topic]
}
