<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# pubsub

## Descrição

Módulo para criação de tópicos e subscriptions do Pub/Sub, com opções de configuração de push/bigquery/dead-letter.

## Uso

```hcl
module "pubsub" {
  source = "../../modules/gcp/pubsub"
  gcp_project = var.project_id
  topic_name = "my-topic"
}
```

## Principais variáveis

- `topic_create`, `topic_name`, `subscription_create`, `subscription_name`, `push_config`

Ver detalhes em `variables.tf`.
