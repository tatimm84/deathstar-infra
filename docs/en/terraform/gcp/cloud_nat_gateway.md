<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# cloud_nat_gateway

Descrição

Criação de Cloud Router e Cloud NAT, incluindo regras e endereços IP dedicados.

Exemplo de uso

```hcl
module "nat" {
  source = "../../terraform/modules/gcp/cloud_nat_gateway"
  gcp_project = var.project_id
  router = "my-router"
  nat = "my-nat"
}
```

Principais variáveis

- `router`, `network`, `nat`, `nat_ips`, `enable_dynamic_port_allocation`

Principais outputs

- `cloud_router_id`, `cloud_router_name`, `cloud_router_self_link`

Detalhes

Ver `terraform/modules/gcp/cloud_nat_gateway/variables.tf` e `outputs.tf`.
