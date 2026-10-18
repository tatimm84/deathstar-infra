# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# OUTPUTS
# --------------------------------------------------------------------
output "bucket_id" {
  description = "Cloud storage bucket id"
  value       = length(google_storage_bucket.bucket) > 0 ? google_storage_bucket.bucket[0].id : null
}
output "bucket_name" {
  description = "Cloud storage bucket name"
  value       = length(google_storage_bucket.bucket) > 0 ? google_storage_bucket.bucket[0].name : null
}
output "bucket_self_link" {
  description = "Cloud storage bucket self link"
  value       = length(google_storage_bucket.bucket) > 0 ? google_storage_bucket.bucket[0].self_link : null
}
output "object_id" {
  description = "Cloud storage object id"
  value       = length(google_storage_bucket_object.object) > 0 ? google_storage_bucket_object.object[0].id : null
}
output "object_name" {
  description = "Cloud storage object name"
  value       = length(google_storage_bucket_object.object) > 0 ? google_storage_bucket_object.object[0].name : null
}
output "object_self_link" {
  description = "Cloud storage object self link"
  value       = length(google_storage_bucket_object.object) > 0 ? google_storage_bucket_object.object[0].self_link : null
}
