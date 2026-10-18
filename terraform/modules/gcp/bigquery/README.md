<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# bigquery

## Descrição

Módulo para criação e gerenciamento de datasets, tabelas, rotinas e transfer jobs do BigQuery.

## Uso

```hcl
module "bigquery" {
  source      = "../../modules/gcp/bigquery"
  gcp_project = var.project_id
  dataset_create = true
  dataset_id = "my_dataset"
}
```

## Principais variáveis

- `dataset_create`, `dataset_id`, `table_create`, `table_id`, `schema`

## Principais outputs

- `dataset_id`, `table_id`, `routine_id`, `data_transfer_id`

## Ver detalhes

Consulte `variables.tf` e `outputs.tf`.

## Comandos úteis

```bash
grep -E "^variable \"" -n variables.tf | sed -E 's/variable \"(.+)\" \{/\1/'
grep -E "^output \"" -n outputs.tf | sed -E 's/output \"(.+)\" \{/\1/'
```
