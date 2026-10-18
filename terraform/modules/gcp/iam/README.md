<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# iam

## Descrição

Módulo para criação de service accounts, bindings IAM e políticas reutilizáveis.

## Uso

```hcl
module "iam" {
  source = "../../modules/gcp/iam"
  gcp_project = var.project_id
  sa_create = true
  service_account_id = "my-sa"
}
```

## Principais variáveis

- `sa_create`, `service_account_id`, `iam_role`, `iam_member`, `iam_members`

Ver detalhes em `variables.tf`.
