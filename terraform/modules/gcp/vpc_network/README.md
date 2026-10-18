<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# vpc_network

## Descrição

Módulo para criação/gerenciamento de VPCs, subnetworks, IPs reservados, firewall rules e access connectors.

## Uso

```hcl
module "vpc" {
  source = "../../modules/gcp/vpc_network"
  gcp_project = var.project_id
  network = "my-network"
}
```

## Principais variáveis

- `network_create`, `network`, `subnetwork_create`, `subnetwork`, `firewall_name`, `access_connector`

Ver detalhes em `variables.tf`.
