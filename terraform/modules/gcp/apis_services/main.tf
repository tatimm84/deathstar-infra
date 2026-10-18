# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# APIS & SERVICES
# --------------------------------------------------------------------
resource "google_project_service" "apis_services" {
  project                    = var.gcp_project
  service                    = var.service
  disable_dependent_services = var.disable_dependent_services
  disable_on_destroy         = var.disable_on_destroy
}
