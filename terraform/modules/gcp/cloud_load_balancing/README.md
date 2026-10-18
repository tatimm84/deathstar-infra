<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# cloud_load_balancing

## Descrição

Módulo para configurar balanceadores de carga (global/regional), proxies, url-maps, backend services e health-checks.

## Uso

```hcl
module "lb" {
  source = "../../modules/gcp/cloud_load_balancing"
  gcp_project = var.project_id
  forwarding_rule = "my-fr"
}
```

## Principais variáveis

- `forwarding_rule`, `target`, `backend_service`, `ip_address`, `ports`, `ssl_certificates`

## Principais outputs

- `global_forwarding_rule_id`, `regional_forwarding_rule_id`, `https_proxy_id`, `global_url_map_id`, `health_check_id`

Ver detalhes em `variables.tf` e `outputs.tf`.

## Comandos úteis

```bash
grep -E "^variable \"" -n variables.tf | sed -E 's/variable \"(.+)\" \{/\1/'
grep -E "^output \"" -n outputs.tf | sed -E 's/output \"(.+)\" \{/\1/'
```
