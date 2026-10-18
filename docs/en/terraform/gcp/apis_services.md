<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# Module: apis_services

Short: Enable/disable Google APIs & Services in a project.

## Example

```hcl
module "apis_services" {
  source      = "../modules/gcp/apis_services"
  gcp_project = var.gcp_project
  service     = "compute.googleapis.com"
}
```

## Variables

| Name                       | Type   | Default | Description                                          |
| -------------------------- | ------ | ------- | ---------------------------------------------------- |
| gcp_project                | string | —       | GCP project id                                       |
| service                    | string | —       | API/service to enable, e.g. `compute.googleapis.com` |
| disable_dependent_services | bool   | null    | Whether to disable dependent services                |
| disable_on_destroy         | bool   | null    | Disable the API when the resource is destroyed       |

See the module `variables.tf` for the complete set of options: `terraform/modules/gcp/apis_services/variables.tf`.

## Outputs

| Name                 | Description                             |
| -------------------- | --------------------------------------- |
| apis_service_id      | Apis & services resource id             |
| apis_service_service | The service name enabled in the project |

See `terraform/modules/gcp/apis_services/outputs.tf` for implementation details.
