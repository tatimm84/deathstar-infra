<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# Cloud Tasks Module

Este módulo cria e gerencia filas do Google Cloud Tasks seguindo os padrões do projeto DeathStar.

## Estrutura

```
terraform/modules/gcp/tasks/
├── main.tf          # Recursos principais
├── variables.tf     # Variáveis do módulo
└── outputs.tf       # Outputs do módulo
```

## Recursos Criados

- `google_cloud_tasks_queue` - Fila do Cloud Tasks
- `google_cloud_tasks_queue_iam_member` - Permissões IAM para a fila

## Uso

1. Coloque os arquivos JSON de configuração em: `../infra/gcp/auto/tasks/`
2. Execute: `terraform plan` e `terraform apply`

## Variáveis de Template Disponíveis

- `${__project_name__}` - Nome do projeto GCP
- `${__env__}` - Ambiente (dev, staging, prod)
- `${__region__}` - Região GCP
- `${__zone__}` - Zona GCP
- `${__project_number__}` - Número do projeto GCP
- `${__uid_now__}` - Timestamp único

## Configurações Principais

- **queue_name**: Nome da fila
- **rate_limits**: Limites de taxa de envio
- **retry_config**: Configuração de retry
- **stackdriver_logging_config**: Configuração de logs
- **iam_members**: Membros com permissões na fila
