<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# ssl_security

## Descrição

Módulo para gerenciar certificados (Certificate Manager / google_compute_ssl_certificate), SSL policies e Cloud Armor.

## Uso

```hcl
module "ssl" {
  source = "../../modules/gcp/ssl_security"
  gcp_project = var.project_id
  ssl_certificate = "my-cert"
}
```

## Principais variáveis

- `certificate`, `private_key`, `ssl_certificate`, `ssl_policy`, `armor`

## Principais outputs

- `ssl_certificate_id`, `ssl_policy_id`, `armor_policy_id`

Ver detalhes em `variables.tf` e `outputs.tf`.
