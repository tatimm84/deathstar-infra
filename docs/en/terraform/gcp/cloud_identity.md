<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# cloud_identity

Descrição

Gerencia grupos e memberships no Cloud Identity.

Exemplo de uso

```hcl
module "cloud_identity" {
  source = "../../terraform/modules/gcp/cloud_identity"
  gcp_project = var.project_id
  display_name = "team-name"
}
```

Principais variáveis (resumo)

- `parent`, `display_name`, `description`, `initial_group_config`, `labels`

Principais outputs (resumo)

- `identity_group_id`, `identity_group_name`, `identity_group_membership_id`

Detalhes

Ver `terraform/modules/gcp/cloud_identity/variables.tf` e `outputs.tf`.
