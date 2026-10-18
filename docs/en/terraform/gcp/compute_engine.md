<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# Module: compute_engine

Short: Create Compute Engine instances, instance groups and related resources.

## Example

```hcl
module "compute_engine" {
  source      = "../modules/gcp/compute_engine"
  gcp_project = var.gcp_project
  name        = "my-instance"
}
```

## Variables

Below are the variables exposed by the module. See `terraform/modules/gcp/compute_engine/variables.tf` for any additional or advanced options.

| Name                         | Type         | Default                 | Description                        |
| ---------------------------- | ------------ | ----------------------- | ---------------------------------- |
| gcp_project                  | string       | —                       | GCP project id                     |
| gcp_region                   | string       | southamerica-east1      | GCP region                         |
| gcp_zone                     | string       | southamerica-east1-b    | GCP zone                           |
| name                         | string       | null                    | Compute Engine instance name       |
| machine_type                 | string       | null                    | Machine type                       |
| allow_stopping_for_update    | bool         | null                    | Allow stopping for update          |
| deletion_protection          | bool         | null                    | Deletion protection                |
| description                  | string       | null                    | Description                        |
| desired_status               | string       | null                    | Desired status                     |
| enable_display               | bool         | null                    | Enable display                     |
| hostname                     | string       | null                    | Hostname                           |
| labels                       | map(string)  | null                    | Labels                             |
| metadata                     | map(string)  | null                    | Metadata key/value pairs           |
| metadata_startup_script      | string       | null                    | Startup script                     |
| min_cpu_platform             | string       | null                    | Minimum CPU platform               |
| resource_policies            | list(string) | null                    | Resource policies                  |
| tags                         | list(string) | null                    | Network tags                       |
| boot_disk                    | any          | null                    | Boot disk configuration            |
| scratch_disk                 | any          | null                    | Scratch disks                      |
| attached_disk                | any          | null                    | Attached disks                     |
| network_interface            | any          | null                    | Network interface configuration    |
| service_account              | any          | null                    | Service account                    |
| scheduling                   | any          | null                    | Scheduling options                 |
| guest_accelerator            | any          | null                    | GPU/accelerator configuration      |
| shielded_instance_config     | any          | null                    | Shielded instance configuration    |
| confidential_instance_config | any          | null                    | Confidential VM config             |
| advanced_machine_features    | any          | null                    | Advanced machine features          |
| reservation_affinity         | any          | null                    | Reservation affinity               |
| backup_create                | bool         | null                    | Create scheduled backups           |
| backup_name                  | string       | null                    | Backup name                        |
| backup_description           | string       | null                    | Backup description                 |
| snapshot_schedule_policy     | any          | null                    | Snapshot schedule policy           |
| group_placement_policy       | any          | null                    | Group placement policy             |
| instance_schedule_policy     | any          | null                    | Instance schedule policy           |
| iam_type                     | string       | member                  | IAM binding type (default: member) |
| iam_member                   | string       | allAuthenticatedUsers   | IAM member default                 |
| iam_members                  | list(string) | [allAuthenticatedUsers] | IAM members list                   |
| iam_condition                | any          | null                    | IAM condition expression           |

## Outputs

| Name               | Description                  |
| ------------------ | ---------------------------- |
| instance_id        | Compute Engine instance id   |
| instance_name      | Compute Engine instance name |
| instance_self_link | Instance self link           |
| backup_id          | Backup resource id           |
| backup_name        | Backup name                  |
| backup_self_link   | Backup self link             |

See `terraform/modules/gcp/compute_engine/variables.tf` and `outputs.tf` for implementation details.
