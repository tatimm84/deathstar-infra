<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# Terraform overview

Short: High-level description of the Terraform layout and how modules are organized.

## Layout

- `terraform/` — top-level Terraform configuration and `modules/` directory.
- `terraform/modules/gcp/` — reusable GCP modules (artifact_registry, cloud_run, compute_engine, etc.).
- `terraform/variables.tf` and `terraform/outputs.tf` — repo-level variables and outputs.

## Where to find module docs

- Generated module docs are under `docs/terraform/gcp/` and there is an index at `docs/terraform/gcp/index.md`.

## How to test modules locally

1. Use a disposable project or mock credentials.
2. Run `terraform init` and `terraform validate` in the module or root folder.
3. Use `terraform plan` with `-var` overrides to simulate inputs.

## Notes

- Many modules accept standard variables like `gcp_project`, `gcp_region`, and `gcp_zone`.
- Some modules include advanced options documented in their corresponding `variables.tf` files; consult `terraform/modules/gcp/<module>/variables.tf` for authoritative definitions.
