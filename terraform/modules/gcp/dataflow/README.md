<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# dataflow

## Descrição

Módulo para execução de jobs Dataflow usando templates, com parâmetros, labels e controle de workers.

## Uso

```hcl
module "dataflow" {
  source = "../../modules/gcp/dataflow"
  gcp_project = var.project_id
  name = "etl-job"
  template_gcs_path = "gs://my-bucket/templates/template"
}
```

## Principais variáveis

- `template_gcs_path`, `parameters`, `max_workers`, `service_account_email`

Ver detalhes em `variables.tf`.
