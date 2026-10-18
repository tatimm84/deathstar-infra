# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# OUTPUTS
# --------------------------------------------------------------------
output "topic_id" {
  description = "Topic ID"
  value       = length(google_pubsub_topic.topic) > 0 ? google_pubsub_topic.topic[0].id : null
}

output "subscription_id" {
  description = "Topic ID"
  value       = length(google_pubsub_subscription.subscription) > 0 ? google_pubsub_subscription.subscription[0].id : null
}
