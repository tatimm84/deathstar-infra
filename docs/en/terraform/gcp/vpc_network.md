<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# Module: vpc_network

Short: Manage VPC networks, subnetworks, IP addresses, firewall policies and service networking connections.

## Example

```hcl
module "vpc_network" {
  source      = "../modules/gcp/vpc_network"
  gcp_project = var.gcp_project
  network     = "my-network"
}
```

## Variables

| Name                    | Type   | Default | Description                        |
| ----------------------- | ------ | ------- | ---------------------------------- |
| gcp_project             | string | —       | GCP project id                     |
| network_create          | bool   | true    | Whether to create the network      |
| network                 | string | null    | Network name                       |
| auto_create_subnetworks | bool   | null    | Whether to auto-create subnetworks |
| subnetwork_create       | bool   | true    | Whether to create subnetworks      |
| subnetwork              | string | null    | Subnetwork name                    |
| ip_cidr_range           | string | null    | Subnetwork IPv4 CIDR range         |
| firewall_name           | string | null    | Firewall name                      |

See `terraform/modules/gcp/vpc_network/variables.tf` for the full set of options.

## Outputs

| Name           | Description      |
| -------------- | ---------------- |
| global_ip_id   | Global IP id     |
| global_ip_name | Global IP name   |
| network_id     | VPC network id   |
| network_name   | VPC network name |
| subnetwork_id  | Subnetwork id    |

See `terraform/modules/gcp/vpc_network/outputs.tf` for details.
