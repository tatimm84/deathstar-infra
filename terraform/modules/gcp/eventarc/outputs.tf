# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# OUTPUTS
# --------------------------------------------------------------------
output "eventarc_trigger_id" {
  description = "Eventarc trigger id"
  value       = google_eventarc_trigger.trigger.id
}
output "eventarc_trigger_name" {
  description = "Eventarc trigger name"
  value       = google_eventarc_trigger.trigger.name
}
