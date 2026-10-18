<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# Module: gcloud

Short: Helper to run gcloud commands or staged operations described by `sha1_json`/`cmd_instruction`.

## Example

```hcl
module "gcloud" {
  source      = "../modules/gcp/gcloud"
  gcp_project = var.gcp_project
}
```

## Variables

| Name            | Type   | Default            | Description                            |
| --------------- | ------ | ------------------ | -------------------------------------- |
| gcp_project     | string | —                  | GCP project id                         |
| gcp_region      | string | southamerica-east1 | GCP region                             |
| sha1_json       | string | null               | Hash/json reference used by the helper |
| cmd_instruction | string | true               | Command instruction or flag            |

See `terraform/modules/gcp/gcloud/variables.tf` for details.

## Outputs

This module does not expose Terraform outputs in `outputs.tf`.
