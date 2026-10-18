# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# REST API
# https://sonarcloud.io/web_api
# --------------------------------------------------------------------
# Trigger
# resource "terraform_data" "trigger" {
#     count = var.image_name != null ? 1 : 0
#     input = join("-", [ var.triggers.dir_sha1, var.sha1_json ])
#     depends_on = [ google_artifact_registry_repository.repo ]
# }

resource "null_resource" "get_request" {
  count = var.method == "GET" ? 1 : 0
  provisioner "local-exec" {
    command = <<EOT
            curl --request ${var.method} "https://sonarcloud.io/api/measures/component?metricKeys=ncloc%2Ccode_smells%2Ccomplexity&component=my_project_key"
            --header "Authorization: Bearer ${var.token}"
            --verbose
        EOT
  }
}
resource "null_resource" "post_request" {
  count = var.method == "POST" ? 1 : 0
  provisioner "local-exec" {
    command = <<EOT
            curl --request ${var.method} "${var.url}"
            --header "Authorization: Bearer ${var.token}"
            --header "Content-Type: application/json"
            --data "${var.data}"
            --verbose
        EOT
  }
}
