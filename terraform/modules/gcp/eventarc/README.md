<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# eventarc

## Descrição

Módulo para criação de triggers Eventarc, com suporte a canais, filtros e destinos.

## Uso

```hcl
module "eventarc" {
  source = "../../modules/gcp/eventarc"
  gcp_project = var.project_id
  name = "my-trigger"
}
```

## Principais variáveis

- `channel`, `destination`, `matching_criteria`, `transport`

Ver detalhes em `variables.tf`.
