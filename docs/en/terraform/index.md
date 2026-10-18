<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# Terraform documentation

Esta seção centraliza a documentação dos artefatos Terraform presentes neste repositório.

## Conteúdo

- [GCP modules](gcp/index.md) — documentação dos módulos GCP contidos em `terraform/modules/gcp/`.

## Como usar

1. Consulte a documentação do módulo desejado em `docs/terraform/gcp/`.
2. Para executar localmente, inicialize o Terraform e use `-var-file` apropriado:

```bash
terraform init -backend-config="bucket=<bucket>" -backend-config="prefix=sz-deathStar-infra"
terraform plan -var-file="envs/dev.tfvars"
```

## Recomendações

- Use backend remoto (GCS) para o state.
- Execute `tflint` e `checkov` como parte do CI.
