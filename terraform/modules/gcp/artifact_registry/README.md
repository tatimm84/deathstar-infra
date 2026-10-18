<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# artifact_registry

## Descrição

Gerencia repositórios Artifact Registry e imagens (Docker/Maven/etc.). Suporta criação de repositórios, políticas de limpeza e configuração de builds.

## Uso

```hcl
module "artifact_registry" {
  source      = "../../modules/gcp/artifact_registry"
  gcp_project = var.project_id
  gcp_region  = var.region
  repository_create = true
  repository_id = "my-repo"
}
```

## Principais variáveis

- `gcp_project`, `gcp_region`
- `repository_create`, `repository_id`, `format`

## Principais outputs

- `repository_id`, `repository_name`

## Ver detalhes

Consulte `variables.tf` e `outputs.tf`.

## Comandos úteis

```bash
grep -E "^variable \"" -n variables.tf | sed -E 's/variable \"(.+)\" \{/\1/'
grep -E "^output \"" -n outputs.tf | sed -E 's/output \"(.+)\" \{/\1/'
```
