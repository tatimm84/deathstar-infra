<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# Módulos Terraform

Esta pasta (`modules/`) contém módulos reutilizáveis organizados por provedor/propósito. Cada módulo deve ser autocontido, com `main.tf`, `variables.tf` e `outputs.tf` (quando aplicável).

## Estrutura recomendada de um módulo

- `main.tf` — recursos principais do módulo.
- `variables.tf` — variáveis de entrada com descrições e valores padrão quando aplicável.
- `outputs.tf` — saídas exportadas pelo módulo.
- `README.md` — documentação do módulo, explicando uso, variáveis importantes e exemplos.

## Como consumir um módulo localmente

```hcl
module "example" {
  source = "../../modules/gcp/cloud_run"

  project_id = var.project_id
  name       = "my-service"
  # ... outros inputs específicos
}
```

## Boas práticas

- Expor inputs mínimos necessários e usar valores padrão sensatos.
- Validar entradas com `validation` blocks quando aplicável (Terraform 0.13+).
- Documentar outputs importantes para facilitar integração entre módulos.
- Evitar efeitos colaterais inesperados (por exemplo: não criar recursos globais sem ser óbvio).

## Lista de coleções

- `gcp/` — módulos específicos para recursos Google Cloud (ver `modules/gcp/README.md`).
- `rest_api/` — módulo para REST APIs (documentação própria no módulo).
- `utils/` — utilitários e helpers reutilizáveis.
