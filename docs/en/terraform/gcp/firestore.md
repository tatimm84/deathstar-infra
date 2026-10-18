<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# Module: firestore

Short: Manage Firestore databases, indexes and documents.

## Example

```hcl
module "firestore" {
  source      = "../modules/gcp/firestore"
  gcp_project = var.gcp_project
  database    = "default"
}
```

## Variables

| Name                              | Type   | Default            | Description                                   |
| --------------------------------- | ------ | ------------------ | --------------------------------------------- |
| gcp_project                       | string | —                  | GCP project id                                |
| gcp_region                        | string | southamerica-east1 | GCP region                                    |
| database_create                   | bool   | true               | Create a Firestore database                   |
| database                          | string | —                  | Firestore database name                       |
| type                              | string | null               | Firestore database type                       |
| concurrency_mode                  | string | null               | Firestore database concurrency mode           |
| app_engine_integration_mode       | string | null               | App Engine integration mode for the database  |
| point_in_time_recovery_enablement | string | null               | Point-in-time recovery enablement             |
| delete_protection_state           | string | null               | Delete protection state                       |
| deletion_policy                   | string | null               | Deletion policy                               |
| collection                        | string | null               | Firestore collection (for index/document ops) |
| api_scope                         | string | null               | Index API scope                               |
| query_scope                       | string | null               | Index query scope                             |
| index_fields                      | any    | null               | Index fields definition (no explicit type)    |
| document_id                       | string | null               | Document id                                   |
| document_fields                   | string | null               | Document fields specification                 |

See `terraform/modules/gcp/firestore/variables.tf` for the authoritative definitions.

## Outputs

| Name          | Description             |
| ------------- | ----------------------- |
| database_id   | Firestore database id   |
| database_name | Firestore database name |
| document_id   | Firestore document id   |
| document_name | Firestore document name |

See `terraform/modules/gcp/firestore/outputs.tf` for implementation details.
