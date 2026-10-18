<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# Module: workflows

Short: Create Workflows with source contents, call logging and service account configuration.

## Example

```hcl
module "workflows" {
  source      = "../modules/gcp/workflows"
  gcp_project = var.gcp_project
  name        = "my-workflow"
}
```

## Variables

| Name            | Type        | Default | Description                          |
| --------------- | ----------- | ------- | ------------------------------------ |
| gcp_project     | string      | —       | GCP project id                       |
| name            | string      | —       | Workflow name                        |
| source_contents | string      | null    | Workflow source contents (YAML/JSON) |
| service_account | string      | null    | Service account to run the workflow  |
| labels          | map(string) | null    | Labels for the workflow              |

See `terraform/modules/gcp/workflows/variables.tf` for details.

## Outputs

| Name          | Description   |
| ------------- | ------------- |
| workflow_id   | Workflow id   |
| workflow_name | Workflow name |

See `terraform/modules/gcp/workflows/outputs.tf` for more.
