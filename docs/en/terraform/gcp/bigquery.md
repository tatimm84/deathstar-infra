<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# Module: bigquery

Short: Create BigQuery datasets, tables, transfers, routines.

## Example

```hcl
module "bigquery" {
  source      = "../modules/gcp/bigquery"
  gcp_project = var.gcp_project
  dataset_id  = "my_dataset"
}
```

## Variables

| Name           | Type        | Default            | Description                     |
| -------------- | ----------- | ------------------ | ------------------------------- |
| gcp_project    | string      | —                  | GCP project id                  |
| gcp_region     | string      | us-central1 | GCP region                      |
| dataset_create | bool        | true               | Create dataset                  |
| dataset_id     | string      | —                  | Dataset id                      |
| table_create   | bool        | true               | Create table                    |
| table_id       | string      | null               | Table id (optional)             |
| labels         | map(string) | null               | Labels applied to dataset/table |

This module exposes many more variables (transfers, routines, schema, encryption). See `terraform/modules/gcp/bigquery/variables.tf` for the complete list.

## Outputs

| Name             | Description               |
| ---------------- | ------------------------- |
| dataset_id       | BigQuery dataset id       |
| table_id         | BigQuery table id         |
| data_transfer_id | Data transfer resource id |
| routine_id       | Routine id                |

See `terraform/modules/gcp/bigquery/outputs.tf` for the full outputs.
