# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# OUTPUTS
# --------------------------------------------------------------------
output "object_id" {
  description = "Storage object id"
  value       = module.object_zip.object_id
}
output "cloud_function_gen1_id" {
  description = "Cloud function gen 1 id"
  value       = length(google_cloudfunctions_function.function) > 0 ? google_cloudfunctions_function.function[0].id : null
}
output "cloud_function_gen1_name" {
  description = "Cloud function gen 1 name"
  value       = length(google_cloudfunctions_function.function) > 0 ? google_cloudfunctions_function.function[0].name : null
}
output "cloud_function_gen2_id" {
  description = "Cloud function gen 2 id"
  value       = length(google_cloudfunctions2_function.function) > 0 ? google_cloudfunctions2_function.function[0].id : null
}
output "cloud_function_gen2_name" {
  description = "Cloud function gen 2 name"
  value       = length(google_cloudfunctions2_function.function) > 0 ? google_cloudfunctions2_function.function[0].name : null
}
output "cloud_function_member" {
  description = "Cloud function iam member"
  value       = length(google_cloudfunctions_function_iam_member.fn_invoker) > 0 ? google_cloudfunctions_function_iam_member.fn_invoker[0].member : null
}
