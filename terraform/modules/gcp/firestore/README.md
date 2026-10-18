<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# firestore

## Descrição

Módulo para gerenciar instâncias do Firestore (databases, indexes, documents) e suas políticas.

## Uso

```hcl
module "firestore" {
  source = "../../modules/gcp/firestore"
  gcp_project = var.project_id
  database = "(default)"
}
```

## Principais variáveis

- `database_create`, `database`, `type`, `collection`, `index_fields`

Ver detalhes em `variables.tf`.
