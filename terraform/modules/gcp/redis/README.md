<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# redis (memorystore)

## Descrição

Módulo para criação de instâncias Memorystore Redis com configuração de rede, versão e escalabilidade.

## Uso

```hcl
module "redis" {
  source = "../../modules/gcp/redis"
  gcp_project = var.project_id
  name = "my-redis"
  memory_size_gb = 4
}
```

## Principais variáveis

- `name`, `memory_size_gb`, `redis_version`, `replica_count`, `authorized_network`

Ver detalhes em `variables.tf`.
