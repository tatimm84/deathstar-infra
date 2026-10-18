<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# Module: k8s_engine (GKE)

Short: Provision GKE clusters and node pools with flexible network and features configuration.

## Example

```hcl
module "k8s_engine" {
  source      = "../modules/gcp/k8s_engine"
  gcp_project = var.gcp_project
  gke_name    = "my-cluster"
}
```

## Variables

| Name                    | Type   | Default | Description              |
| ----------------------- | ------ | ------- | ------------------------ |
| gcp_project             | string | —       | GCP project id           |
| gke_name                | string | null    | GKE cluster name         |
| gke_k8s_version         | string | null    | Kubernetes version       |
| gke_isregional          | bool   | true    | Is the cluster regional? |
| gke_node_pools_settings | any    | null    | Node pools configuration |

See `terraform/modules/gcp/k8s_engine/variables.tf` for advanced configuration.

## Outputs

| Name           | Description          |
| -------------- | -------------------- |
| gke_cluster_id | GKE cluster id       |
| gke_endpoint   | GKE cluster endpoint |
| gke_name       | GKE cluster name     |

See `terraform/modules/gcp/k8s_engine/outputs.tf` for details.
