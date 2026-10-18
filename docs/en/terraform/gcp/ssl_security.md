<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# Module: ssl_security

Short: Manage SSL certificates, SSL policies and Cloud Armor policies.

## Example

```hcl
module "ssl_security" {
  source      = "../modules/gcp/ssl_security"
  gcp_project = var.gcp_project
}
```

## Variables

| Name        | Type   | Default | Description                 |
| ----------- | ------ | ------- | --------------------------- |
| gcp_project | string | —       | GCP project id              |
| certificate | string | null    | Certificate content or name |
| private_key | string | null    | Private key for certificate |
| ssl_policy  | string | null    | SSL policy name             |
| profile     | string | null    | SSL profile                 |

See `terraform/modules/gcp/ssl_security/variables.tf` for full details.

## Outputs

| Name                 | Description           |
| -------------------- | --------------------- |
| ssl_certificate_id   | SSL certificate id    |
| ssl_certificate_name | SSL certificate name  |
| armor_policy_id      | Cloud Armor policy id |

See `terraform/modules/gcp/ssl_security/outputs.tf` for details.
