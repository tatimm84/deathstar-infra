<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# Module: pubsub

Short: Create Pub/Sub topics and subscriptions with options for push sinks, BigQuery sinks, retry and dead-letter policies.

## Example

```hcl
module "pubsub" {
  source      = "../modules/gcp/pubsub"
  gcp_project = var.gcp_project
  topic_name  = "my-topic"
}
```

## Variables

| Name                | Type        | Default | Description                         |
| ------------------- | ----------- | ------- | ----------------------------------- |
| gcp_project         | string      | —       | GCP project id                      |
| topic_create        | string      | null    | Whether to create the topic         |
| topic_name          | string      | null    | Topic name                          |
| labels              | map(string) | null    | Topic labels                        |
| subscription_create | string      | null    | Whether to create a subscription    |
| subscription_name   | string      | null    | Subscription name                   |
| push_config         | any         | null    | Push configuration for subscription |

See `terraform/modules/gcp/pubsub/variables.tf` for advanced options.

## Outputs

| Name            | Description             |
| --------------- | ----------------------- |
| topic_id        | Pub/Sub topic id        |
| subscription_id | Pub/Sub subscription id |

See `terraform/modules/gcp/pubsub/outputs.tf` for details.
