# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# OUTPUTS
# --------------------------------------------------------------------
output "cloud_router_id" {
  description = "Cloud router id"
  value       = google_compute_router.router.id
}
output "cloud_router_name" {
  description = "Cloud router name"
  value       = google_compute_router.router.name
}
output "cloud_router_self_link" {
  description = "Cloud router self link"
  value       = google_compute_router.router.self_link
}
