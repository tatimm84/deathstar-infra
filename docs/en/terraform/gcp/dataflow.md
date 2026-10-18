<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# Module: dataflow

Short: Run Dataflow jobs using templates with parameters, labels and network configuration.

## Example

```hcl
module "dataflow" {
  source      = "../modules/gcp/dataflow"
  gcp_project = var.gcp_project
  name        = "my-dataflow-job"
}
```

## Variables

| Name                         | Type        | Default              | Description                           |
| ---------------------------- | ----------- | -------------------- | ------------------------------------- |
| gcp_project                  | string      | —                    | GCP project id                        |
| gcp_region                   | string      | southamerica-east1   | GCP region                            |
| gcp_zone                     | string      | southamerica-east1-c | GCP zone                              |
| name                         | string      | —                    | Dataflow job name                     |
| template_gcs_path            | string      | —                    | GCS path to the Dataflow job template |
| temp_gcs_region              | string      | —                    | GCS region for temporary data         |
| parameters                   | map(string) | null                 | Dataflow job parameters               |
| labels                       | map(string) | null                 | Job labels                            |
| transform_name_mapping       | map(string) | null                 | Transform name mapping                |
| max_workers                  | number      | null                 | Max workers                           |
| on_delete                    | string      | null                 | On-delete behavior                    |
| skip_wait_on_job_termination | bool        | null                 | Skip waiting on job termination       |
| service_account_email        | string      | null                 | Service account email                 |
| network                      | string      | null                 | Network                               |
| subnetwork                   | string      | null                 | Subnetwork                            |
| machine_type                 | string      | null                 | Machine type                          |
| kms_key_name                 | string      | null                 | KMS key name                          |
| ip_configuration             | string      | null                 | IP configuration                      |
| additional_experiments       | set(string) | null                 | Additional experiments                |
| enable_streaming_engine      | bool        | null                 | Enable streaming engine               |

See `terraform/modules/gcp/dataflow/variables.tf` for the authoritative definitions.

## Outputs

| Name               | Description        |
| ------------------ | ------------------ |
| dataflow_job_id    | Dataflow job id    |
| dataflow_job_type  | Dataflow job type  |
| dataflow_job_state | Dataflow job state |

See `terraform/modules/gcp/dataflow/outputs.tf` for implementation details.
