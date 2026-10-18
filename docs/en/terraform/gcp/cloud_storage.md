<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# Module: cloud_storage

Short: Manage Cloud Storage buckets, objects, CORS, lifecycle and ACLs.

## Example

```hcl
module "cloud_storage" {
  source      = "../modules/gcp/cloud_storage"
  gcp_project = var.gcp_project
  bucket      = "my-bucket"
}
```

## Variables

| Name                        | Type        | Default            | Description                       |
| --------------------------- | ----------- | ------------------ | --------------------------------- |
| gcp_project                 | string      | null               | GCP project id                    |
| gcp_region                  | string      | southamerica-east1 | GCP region                        |
| bucket_create               | bool        | true               | Create the bucket                 |
| bucket                      | string      | —                  | Bucket name                       |
| default_event_based_hold    | bool        | null               | Default event-based hold          |
| enable_object_retention     | bool        | null               | Enable object retention           |
| force_destroy               | bool        | null               | Force destroy bucket              |
| labels                      | map(string) | null               | Bucket labels                     |
| public_access_prevention    | string      | null               | Public access prevention          |
| requester_pays              | bool        | null               | Requester pays                    |
| rpo                         | string      | null               | RPO                               |
| storage_class_bucket        | string      | null               | Bucket storage class              |
| uniform_bucket_level_access | bool        | null               | Uniform bucket level access       |
| autoclass                   | any         | []                 | Autoclass configuration           |
| cors                        | any         | []                 | CORS configuration                |
| custom_placement_config     | any         | []                 | Custom placement config           |
| encryption                  | any         | []                 | Encryption configuration          |
| lifecycle_rule              | any         | []                 | Lifecycle rules                   |
| logging                     | any         | []                 | Logging configuration             |
| retention_policy            | any         | []                 | Retention policy                  |
| soft_delete_policy          | any         | []                 | Soft delete policy                |
| versioning                  | any         | []                 | Versioning configuration          |
| website                     | any         | []                 | Website configuration             |
| object_create               | bool        | true               | Create an object                  |
| name                        | string      | null               | Object name                       |
| content                     | string      | null               | Object content                    |
| object_source               | string      | null               | Object source                     |
| metadata                    | map(string) | null               | Object metadata                   |
| cache_control               | string      | null               | Cache control                     |
| content_disposition         | string      | null               | Content disposition               |
| content_encoding            | string      | null               | Content encoding                  |
| content_language            | string      | null               | Content language                  |
| content_type                | string      | null               | Content type                      |
| detect_md5hash              | string      | null               | Detect md5 hash                   |
| event_based_hold            | bool        | null               | Event-based hold                  |
| kms_key_name                | string      | null               | KMS key name                      |
| object_storage_class        | string      | null               | Object storage class              |
| temporary_hold              | bool        | null               | Temporary hold                    |
| customer_encryption         | any         | []                 | Customer encryption configuration |
| retention                   | any         | []                 | Object retention configuration    |
| acl_role                    | string      | null               | ACL role                          |
| acl_entity                  | string      | null               | ACL entity                        |

See `terraform/modules/gcp/cloud_storage/variables.tf` for full definitions.

## Outputs

| Name             | Description               |
| ---------------- | ------------------------- |
| bucket_id        | Cloud Storage bucket id   |
| bucket_name      | Cloud Storage bucket name |
| bucket_self_link | Bucket self link          |
| object_id        | Cloud Storage object id   |
| object_name      | Cloud Storage object name |
| object_self_link | Object self link          |

See `terraform/modules/gcp/cloud_storage/outputs.tf` for implementation details.
