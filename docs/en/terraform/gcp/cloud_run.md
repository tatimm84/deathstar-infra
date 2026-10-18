<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# Module: cloud_run

Short: Deploy Cloud Run services and jobs and manage IAM.

## Example

```hcl
module "cloud_run" {
  source      = "../modules/gcp/cloud_run"
  gcp_project = var.gcp_project
  name        = "my-service"
}
```

## Variables

| Name           | Type         | Default                   | Description                                  |
| -------------- | ------------ | ------------------------- | -------------------------------------------- |
| gcp_project    | string       | —                         | GCP project id                               |
| cloud_run_type | string       | service                   | Type: `service` or `job`                     |
| name           | string       | —                         | Service or job name                          |
| template       | any          | null                      | Service/job template (containers, revisions) |
| traffic        | any          | null                      | Traffic routing configuration                |
| iam_members    | list(string) | ["allAuthenticatedUsers"] | IAM members to add to the service            |

See `terraform/modules/gcp/cloud_run/variables.tf` for the complete configuration and advanced options.

## Outputs

| Name             | Description            |
| ---------------- | ---------------------- |
| run_service_id   | Cloud Run service id   |
| run_service_name | Cloud Run service name |
| run_service_uri  | Cloud Run service URI  |

See `terraform/modules/gcp/cloud_run/outputs.tf` for details.
