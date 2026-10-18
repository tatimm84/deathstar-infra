<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# Module: dataproc

Short: Manage Dataproc clusters and jobs.

## Example

```hcl
module "dataproc" {
  source      = "../modules/gcp/dataproc"
  gcp_project = var.gcp_project
  name        = "my-dataproc-cluster"
}
```

## Variables

This module currently does not declare Terraform input variables in `variables.tf` beyond standard project/region (they may be commented out). Check the module source for any optional or environment-specific variables.

See `terraform/modules/gcp/dataproc/variables.tf` for details.

## Outputs

This module currently does not declare Terraform outputs in `outputs.tf` (or they are commented out). See the module source for any sample outputs or usage examples.
