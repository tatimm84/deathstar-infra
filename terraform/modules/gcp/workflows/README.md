<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# workflows

## Descrição

Módulo para criação de Workflows GCP (Google Workflows) com definição de steps e integrações.

## Uso

```hcl
module "workflows" {
  source = "../../modules/gcp/workflows"
  gcp_project = var.project_id
  name = "my-workflow"
}
```

Ver detalhes em `variables.tf`.
