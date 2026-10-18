<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# cloud_nat_gateway

## Descrição

Módulo para criação de Cloud Router e Cloud NAT, incluindo regras e IPs.

## Uso

```hcl
module "nat" {
  source = "../../modules/gcp/cloud_nat_gateway"
  gcp_project = var.project_id
  router = "my-router"
  nat = "my-nat"
}
```

## Principais variáveis

- `router`, `network`, `nat`, `nat_ips`, `enable_dynamic_port_allocation`

## Principais outputs

- `cloud_router_id`, `cloud_router_name`, `cloud_router_self_link`

Ver detalhes em `variables.tf` e `outputs.tf`.

## Comandos úteis

```bash
grep -E "^variable \"" -n variables.tf | sed -E 's/variable \"(.+)\" \{/\1/'
grep -E "^output \"" -n outputs.tf | sed -E 's/output \"(.+)\" \{/\1/'
```
