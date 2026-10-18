<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# Module: secret_manager

Short: Manage Secret Manager secrets, versions and IAM bindings.

## Example

```hcl
module "secret_manager" {
  source      = "../modules/gcp/secret_manager"
  gcp_project = var.gcp_project
  secret_id   = "my-secret"
}
```

## Variables

| Name          | Type   | Default | Description               |
| ------------- | ------ | ------- | ------------------------- |
| gcp_project   | string | —       | GCP project id            |
| secret_create | bool   | true    | Create the secret         |
| secret_id     | string | —       | Secret identifier         |
| replication   | any    | null    | Replication configuration |
| rotation      | any    | null    | Rotation configuration    |

See `terraform/modules/gcp/secret_manager/variables.tf` for the full set of options.

## Outputs

| Name         | Description         |
| ------------ | ------------------- |
| secret_id    | Secret resource id  |
| version_id   | Secret version id   |
| version_name | Secret version name |

See `terraform/modules/gcp/secret_manager/outputs.tf` for details.
