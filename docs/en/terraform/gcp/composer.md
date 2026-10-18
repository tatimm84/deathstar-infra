<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# composer

Descrição

Módulo para provisionamento de ambientes Cloud Composer (Airflow).

Exemplo de uso

```hcl
module "composer" {
  source = "../../terraform/modules/gcp/composer"
  gcp_project = var.project_id
  name = "my-composer"
}
```

Principais variáveis

- `composer_version`, `name`, `labels`, `config`, `storage_config`

Principais outputs

- `composer_1_id`, `composer_1_name`, `composer_2_id` (depende da versão)

Detalhes

Ver `terraform/modules/gcp/composer/variables.tf` e `outputs.tf`.
