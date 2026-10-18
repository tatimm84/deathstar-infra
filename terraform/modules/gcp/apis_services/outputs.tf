# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# OUTPUTS
# --------------------------------------------------------------------
output "apis_service_id" {
  description = "Apis & services id"
  value       = google_project_service.apis_services.id
}
output "apis_service_service" {
  description = "Apis & services service"
  value       = google_project_service.apis_services.service
}
