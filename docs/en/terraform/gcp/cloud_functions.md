<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# Module: cloud_functions

Short: Build, store and deploy Cloud Functions (gen1/gen2) with optional storage of artifacts.

## Example

```hcl
module "cloud_functions" {
  source      = "../modules/gcp/cloud_functions"
  gcp_project = var.gcp_project
  name        = "my-fn"
  runtime     = "python311"
}
```

## Variables

| Name                  | Type        | Default | Description                             |
| --------------------- | ----------- | ------- | --------------------------------------- |
| gcp_project           | string      | —       | GCP project id                          |
| source_dir            | string      | —       | Path to function source to archive      |
| bucket                | string      | —       | Cloud Storage bucket to store artifacts |
| name                  | string      | —       | Cloud Function name                     |
| runtime               | string      | —       | Function runtime (e.g. `python311`)     |
| entry_point           | string      | null    | Function entry point                    |
| environment_variables | map(string) | null    | Environment variables for the function  |
| service_account_email | string      | null    | Service account used by the function    |
| timeout               | number      | null    | Timeout in seconds                      |
| trigger_http          | bool        | null    | Expose HTTP trigger                     |

See `terraform/modules/gcp/cloud_functions/variables.tf` for the complete variable list and types.

## Outputs

| Name                     | Description                                |
| ------------------------ | ------------------------------------------ |
| object_id                | Storage object id for the archived source  |
| cloud_function_gen1_id   | Gen1 Cloud Function id                     |
| cloud_function_gen1_name | Gen1 Cloud Function name                   |
| cloud_function_gen2_id   | Gen2 Cloud Function id                     |
| cloud_function_gen2_name | Gen2 Cloud Function name                   |
| cloud_function_member    | IAM member created for function invocation |

See `terraform/modules/gcp/cloud_functions/outputs.tf` for details.
