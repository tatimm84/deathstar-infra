<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# Module: redis

Short: Manage Memorystore (Redis) instances with network and persistence options.

## Example

```hcl
module "redis" {
  source      = "../modules/gcp/redis"
  gcp_project = var.gcp_project
  name        = "my-redis"
}
```

## Variables

| Name           | Type   | Default | Description         |
| -------------- | ------ | ------- | ------------------- |
| gcp_project    | string | —       | GCP project id      |
| name           | string | —       | Redis instance name |
| memory_size_gb | number | —       | Memory size (GB)    |
| tier           | string | null    | Redis tier          |
| redis_version  | string | null    | Redis version       |

See `terraform/modules/gcp/redis/variables.tf` for the full list.

## Outputs

| Name                | Description         |
| ------------------- | ------------------- |
| redis_instance_id   | Redis instance id   |
| redis_instance_name | Redis instance name |
| redis_instance_host | Redis instance host |

See `terraform/modules/gcp/redis/outputs.tf` for details.
