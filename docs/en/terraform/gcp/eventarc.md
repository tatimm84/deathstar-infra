<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# Module: eventarc

Short: Create Eventarc triggers and configure transports/destinations.

## Example

```hcl
module "eventarc" {
  source      = "../modules/gcp/eventarc"
  gcp_project = var.gcp_project
  name        = "my-trigger"
}
```

## Variables

| Name                    | Type        | Default            | Description                                  |
| ----------------------- | ----------- | ------------------ | -------------------------------------------- |
| gcp_project             | string      | —                  | GCP project id                               |
| gcp_region              | string      | us-central1 | GCP region                                   |
| name                    | string      | —                  | Eventarc trigger name                        |
| channel                 | string      | null               | Eventarc channel                             |
| event_data_content_type | string      | null               | Event data content type                      |
| labels                  | map(string) | null               | Labels for the trigger                       |
| service_account         | string      | null               | Service account used by the trigger          |
| destination             | any         | null               | Destination configuration (no explicit type) |
| matching_criteria       | any         | null               | Matching criteria                            |
| transport               | any         | null               | Transport configuration                      |

See `terraform/modules/gcp/eventarc/variables.tf` for full details.

## Outputs

| Name                  | Description           |
| --------------------- | --------------------- |
| eventarc_trigger_id   | Eventarc trigger id   |
| eventarc_trigger_name | Eventarc trigger name |

See `terraform/modules/gcp/eventarc/outputs.tf` for implementation details.
