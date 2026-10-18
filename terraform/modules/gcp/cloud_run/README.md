<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# cloud_run

## Descrição

Módulo para criação de serviços e jobs no Cloud Run (v2), gerenciamento de IAM e configurações de template/traffic.

## Uso

```hcl
module "cloud_run" {
  source = "../../modules/gcp/cloud_run"
  gcp_project = var.project_id
  name = "my-service"
  template = { container = { image = "gcr.io/${var.project_id}/my:tag" } }
}
```

## Principais variáveis

- `cloud_run_type`, `name`, `template`, `labels`, `iam_members`

## Principais outputs

- `run_service_id`, `run_service_name`, `run_service_uri`, `run_job_id`

Ver detalhes em `variables.tf` e `outputs.tf`.

## Comandos úteis

```bash
grep -E "^variable \"" -n variables.tf | sed -E 's/variable \"(.+)\" \{/\1/'
grep -E "^output \"" -n outputs.tf | sed -E 's/output \"(.+)\" \{/\1/'
```
