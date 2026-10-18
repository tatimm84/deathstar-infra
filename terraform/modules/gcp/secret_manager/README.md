<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# secret_manager

## Descrição

Módulo para criação e versão de segredos no Secret Manager.

## Uso

```hcl
module "secrets" {
  source = "../../modules/gcp/secret_manager"
  gcp_project = var.project_id
  # inputs dependem do módulo
}
```

Ver detalhes em `variables.tf` e `outputs.tf`.
