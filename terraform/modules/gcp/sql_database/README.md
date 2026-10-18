<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# sql_database (Cloud SQL)

## Descrição

Módulo para criação de instâncias Cloud SQL, bancos, usuários e gerenciamento de certificados/segredos.

## Uso

```hcl
module "sql" {
  source = "../../modules/gcp/sql_database"
  gcp_project = var.project_id
  sql_instance_name = "my-sql"
}
```

## Principais variáveis

- `sql_instance_create`, `sql_instance_name`, `database_version`, `sql_user_name`, `sql_user_pw`

Ver detalhes em `variables.tf`.
