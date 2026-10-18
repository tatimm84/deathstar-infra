<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# cloud_storage

## Descrição

Módulo para criação de buckets e objetos em Cloud Storage, com opções de versioning, retention, lifecycle e ACLs.

## Uso

```hcl
module "storage" {
  source = "../../modules/gcp/cloud_storage"
  gcp_project = var.project_id
  bucket = "my-bucket"
}
```

## Principais variáveis

- `bucket_create`, `bucket`, `force_destroy`, `labels`, `versioning`, `lifecycle_rule`

## Principais outputs

- `bucket_id`, `bucket_name`, `object_id`

Ver detalhes em `variables.tf` e `outputs.tf`.

## Comandos úteis

```bash
grep -E "^variable \"" -n variables.tf | sed -E 's/variable \"(.+)\" \{/\1/'
grep -E "^output \"" -n outputs.tf | sed -E 's/output \"(.+)\" \{/\1/'
```
