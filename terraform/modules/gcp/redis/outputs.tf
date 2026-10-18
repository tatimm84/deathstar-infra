# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# OUTPUTS
# --------------------------------------------------------------------
output "redis_instance_id" {
  description = "Redis instance id"
  value       = google_redis_instance.redis.id
}
output "redis_instance_name" {
  description = "Redis instance name"
  value       = google_redis_instance.redis.name
}
output "redis_instance_host" {
  description = "Redis instance host"
  value       = google_redis_instance.redis.host
}
