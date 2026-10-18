<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# compute_engine

## Descrição

Módulo para criação de instâncias, discos, recursos de backup e políticas relacionadas ao Compute Engine.

## Uso

```hcl
module "vm" {
  source = "../../modules/gcp/compute_engine"
  gcp_project = var.project_id
  name = "my-vm"
  machine_type = "e2-medium"
}
```

## Principais variáveis

- `name`, `machine_type`, `boot_disk`, `network_interface`, `metadata_startup_script`

## Principais outputs

- `instance_id`, `instance_name`, `backup_id`

Ver detalhes em `variables.tf` e `outputs.tf`.
