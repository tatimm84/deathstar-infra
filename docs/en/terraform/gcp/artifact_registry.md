<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# Module: artifact_registry

Short: Manage Artifact Registry repositories and images.

## Example

```hcl
module "artifact_registry" {
  source      = "../modules/gcp/artifact_registry"
  gcp_project = var.gcp_project
}
```

## Variables

| Name              | Type   | Default            | Description                                    |
| ----------------- | ------ | ------------------ | ---------------------------------------------- |
| gcp_project       | string | —                  | GCP project id                                 |
| gcp_region        | string | southamerica-east1 | GCP region                                     |
| repository_create | bool   | true               | Create the Artifact Registry repository        |
| repository_id     | string | null               | Repository identifier (used when not creating) |

This module includes many additional variables for image build/configuration and cleanup policies. See `terraform/modules/gcp/artifact_registry/variables.tf` for the complete list and examples.

## Outputs

| Name            | Description                       |
| --------------- | --------------------------------- |
| repository_id   | Artifact Registry repository id   |
| repository_name | Artifact Registry repository name |

See `terraform/modules/gcp/artifact_registry/outputs.tf` for implementation details.
