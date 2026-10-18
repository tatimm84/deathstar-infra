<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# dataproc

## Descrição

Módulo placeholder para Dataproc (clusters Hadoop/Spark). Ver arquivos dentro do módulo para status e variáveis disponíveis.

## Uso

```hcl
module "dataproc" {
  source = "../../modules/gcp/dataproc"
  gcp_project = var.project_id
}
```

Nota: este módulo contém trechos comentados; consulte `variables.tf`/`outputs.tf` dentro da pasta.
