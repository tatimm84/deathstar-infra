<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# cloud_scheduler

Descrição

Módulo para criação de jobs no Cloud Scheduler (targets: pubsub, http, app engine), com cron schedule e retry config.

Exemplo de uso

```hcl
module "scheduler" {
  source = "../../terraform/modules/gcp/cloud_scheduler"
  gcp_project = var.project_id
  name = "daily-job"
  schedule = "0 6 * * *"
}
```

Principais variáveis

- `name`, `schedule`, `pubsub_target`, `http_target`, `retry_config`

Principais outputs

- `scheduler_id`, `scheduler_name`

Detalhes

Ver `terraform/modules/gcp/cloud_scheduler/variables.tf` e `outputs.tf`.
