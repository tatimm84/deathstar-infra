<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# k8s_engine (GKE)

## Descrição

Módulo para provisionar clusters GKE (regional/zonal), node pools e opções de rede/segurança.

## Uso

```hcl
module "gke" {
  source = "../../modules/gcp/k8s_engine"
  gcp_project = var.project_id
  gke_name = "my-cluster"
}
```

## Principais variáveis

- `gke_k8s_version`, `gke_name`, `gke_isregional`, `gke_node_pools_settings`

Ver detalhes em `variables.tf`.
