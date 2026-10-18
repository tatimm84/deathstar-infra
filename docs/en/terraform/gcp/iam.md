<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# Module: iam

Short: Manage IAM resources — service accounts, roles, bindings, policies.

## Example

```hcl
module "iam" {
  source      = "../modules/gcp/iam"
  gcp_project = var.gcp_project
}
```

## Variables

| Name               | Type         | Default | Description                  |
| ------------------ | ------------ | ------- | ---------------------------- |
| gcp_project        | string       | —       | GCP project id               |
| sa_create          | bool         | false   | Create a service account     |
| service_account_id | string       | null    | Service account id           |
| display_name       | string       | null    | Service account display name |
| iam_role           | string       | null    | IAM role to apply            |
| iam_member         | string       | null    | IAM member (single)          |
| iam_members        | list(string) | []      | IAM members list             |

See `terraform/modules/gcp/iam/variables.tf` for more options.

## Outputs

| Name              | Description                                                                                  |
| ----------------- | -------------------------------------------------------------------------------------------- |
| (module-specific) | See `terraform/modules/gcp/iam/outputs.tf` for available outputs (service account ids, etc.) |
