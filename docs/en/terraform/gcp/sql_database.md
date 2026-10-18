<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# Module: sql_database

Short: Create Cloud SQL instances, databases, users and certificates.

## Example

```hcl
module "sql_database" {
  source      = "../modules/gcp/sql_database"
  gcp_project = var.gcp_project
  sql_instance_name = "my-instance"
}
```

## Variables

| Name                | Type   | Default | Description                        |
| ------------------- | ------ | ------- | ---------------------------------- |
| gcp_project         | string | —       | GCP project id                     |
| sql_instance_create | bool   | true    | Whether to create the SQL instance |
| sql_instance_name   | string | null    | Instance name                      |
| database_version    | string | null    | Database engine version            |
| sql_db_name         | string | null    | Database name to create            |

See `terraform/modules/gcp/sql_database/variables.tf` for the full set of options.

## Outputs

| Name                     | Description     |
| ------------------------ | --------------- |
| sql_database_instance_id | SQL instance id |

See `terraform/modules/gcp/sql_database/outputs.tf` for details.
