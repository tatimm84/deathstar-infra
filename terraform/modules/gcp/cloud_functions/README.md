<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# cloud_functions

## Descrição

Módulo para empacotar, armazenar e criar Cloud Functions (gen1/gen2), com suporte a triggers, environment variables e IAM.

## Uso

```hcl
module "cloud_functions" {
  source = "../../modules/gcp/cloud_functions"
  gcp_project = var.project_id
  name = "my-fn"
  runtime = "python311"
}
```

## Principais variáveis

- `source_dir`, `bucket`, `name`, `runtime`, `environment_variables`, `service_account_email`

## Principais outputs

- `object_id`, `cloud_function_gen1_id`, `cloud_function_gen2_id`, `cloud_function_member`

Ver detalhes em `variables.tf` e `outputs.tf`.

## Comandos úteis

```bash
grep -E "^variable \"" -n variables.tf | sed -E 's/variable \"(.+)\" \{/\1/'
grep -E "^output \"" -n outputs.tf | sed -E 's/output \"(.+)\" \{/\1/'
```
