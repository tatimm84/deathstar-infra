<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# gcloud

## Descrição

Helpers para executar instruções `gcloud` e operações auxiliares (wrapping scripts). Use com cuidado em pipelines.

## Uso

```hcl
module "gcloud" {
  source = "../../modules/gcp/gcloud"
  gcp_project = var.project_id
  cmd_instruction = "gcloud projects describe ${var.project_id}"
}
```

## Principais variáveis

- `cmd_instruction`, `sha1_json`

Ver detalhes em `variables.tf`.
