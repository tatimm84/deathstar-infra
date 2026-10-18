<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# apis_services

## Descrição

Módulo para habilitar e gerenciar APIs e serviços do Google Cloud (resource: google_project_service).

## Uso

```hcl
module "apis_services" {
  source      = "../../modules/gcp/apis_services"
  gcp_project = var.project_id
  service     = "run.googleapis.com"
}
```

## Principais variáveis

- `gcp_project` — ID do projeto GCP
- `service` — Nome do serviço a ser habilitado (ex.: `run.googleapis.com`)

## Principais outputs

- `apis_service_id` — id do recurso criado
- `apis_service_service` — nome do serviço habilitado

## Ver detalhes

Consulte `variables.tf` e `outputs.tf` para a lista completa de entradas/saídas.

## Comandos úteis

```bash
# listar variáveis
grep -E "^variable \"" -n variables.tf | sed -E 's/variable \"(.+)\" \{/\1/'
# listar outputs
grep -E "^output \"" -n outputs.tf | sed -E 's/output \"(.+)\" \{/\1/'
```
