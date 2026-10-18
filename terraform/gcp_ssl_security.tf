# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# SSL SECURITY
# --------------------------------------------------------------------
locals {
  ssl_security_reader = module.json_ssl_reader.parsed_data
  ssl_security = [
    for item in local.ssl_security_reader : {
      file        = item.source
      content     = item.content
      certificate = file(lookup(item.content, "certificate"))
      private_key = file(lookup(item.content, "private_key"))
    }
  ]
  old = distinct(flatten([
    for file in fileset("${var.SRC_INFRA_PATH}/gcp/auto/ssl_security/", "**") : [{
      file = file
      content = templatefile(
        "${var.SRC_INFRA_PATH}/gcp/auto/ssl_security/${file}",
        {
          "__project_number__" = var.PROJECT_NUMBER,
          "__project_name__"   = var.GCP_PROJECT,
          "__region__"         = var.GCP_REGION,
          "__env__"            = var.ENVIRONMENT,
          "__uid_now__"        = var.UID_NOW
        }
      )
    }]
  ]))
}

module "json_ssl_reader" {
  source = "./modules/utils/reader"

  source_path = "${var.SRC_INFRA_PATH}/gcp/auto/ssl_security/"
  enviroment  = var.ENVIRONMENT
  files_regex = "**"
  template_vars = {
    "__project_number__" = var.PROJECT_NUMBER,
    "__project_name__"   = var.GCP_PROJECT,
    "__region__"         = var.GCP_REGION,
    "__env__"            = var.ENVIRONMENT,
    "__uid_now__"        = var.UID_NOW
  }
}

module "gcp_ssl_security" {
  for_each                    = { for entry in local.ssl_security : "${entry.file}" => entry }
  source                      = "./modules/gcp/ssl_security"
  gcp_project                 = var.GCP_PROJECT
  gcp_region                  = var.GCP_REGION
  ssl_certificate             = lookup(each.value.content, "ssl_certificate", "") != "" ? lookup(each.value.content, "ssl_certificate") : null
  ssl_certificate_type        = lookup(each.value.content, "ssl_certificate_type", "") != "" ? lookup(each.value.content, "ssl_certificate_type") : "global"
  certificate                 = replace(each.value.certificate, "\\n", "\n")
  private_key                 = replace(each.value.private_key, "\\n", "\n")
  ssl_certificate_description = lookup(each.value.content, "ssl_certificate_description", "") != "" ? lookup(each.value.content, "ssl_certificate_description") : null
  name_prefix                 = lookup(each.value.content, "name_prefix", "") != "" ? lookup(each.value.content, "name_prefix") : null
  ssl_policy                  = lookup(each.value.content, "ssl_policy", "") != "" ? lookup(each.value.content, "ssl_policy") : null
  ssl_policy_type             = lookup(each.value.content, "ssl_policy_type", "") != "" ? lookup(each.value.content, "ssl_policy_type") : "global"
  profile                     = lookup(each.value.content, "profile", "") != "" ? lookup(each.value.content, "profile") : null
  min_tls_version             = lookup(each.value.content, "min_tls_version", "") != "" ? lookup(each.value.content, "min_tls_version") : null
  custom_features             = lookup(each.value.content, "custom_features", "") != "" ? lookup(each.value.content, "custom_features") : null
  armor                       = lookup(each.value.content, "armor", "") != "" ? lookup(each.value.content, "armor") : null
  armor_description           = lookup(each.value.content, "armor_description", "") != "" ? lookup(each.value.content, "armor_description") : null
  type                        = lookup(each.value.content, "type", "") != "" ? lookup(each.value.content, "type") : null
  advanced_options_config     = lookup(each.value.content, "advanced_options_config", {}) != {} ? [lookup(each.value.content, "advanced_options_config")] : []
  adaptive_protection_config  = lookup(each.value.content, "adaptive_protection_config", {}) != {} ? [lookup(each.value.content, "adaptive_protection_config")] : []
  recaptcha_options_config    = lookup(each.value.content, "recaptcha_options_config", {}) != {} ? [lookup(each.value.content, "recaptcha_options_config")] : []
  rule                        = try(each.value.content["rule"], {}) != {} ? each.value.content["rule"] : null
  depends_on                  = [module.gcp_apis_services]
}
