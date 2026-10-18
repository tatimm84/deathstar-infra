<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# cloud_identity

## Descrição

Gerencia grupos e memberships no Cloud Identity.

## Uso

```hcl
module "cloud_identity" {
  source = "../../modules/gcp/cloud_identity"
  gcp_project = var.project_id
  display_name = "team-name"
}
```

## Principais variáveis

- `parent`, `display_name`, `description`, `initial_group_config`, `labels`

## Principais outputs

- `identity_group_id`, `identity_group_name`, `identity_group_membership_id`

Ver detalhes em `variables.tf` e `outputs.tf`.

## Comandos úteis

```bash
grep -E "^variable \"" -n variables.tf | sed -E 's/variable \"(.+)\" \{/\1/'
grep -E "^output \"" -n outputs.tf | sed -E 's/output \"(.+)\" \{/\1/'
```
