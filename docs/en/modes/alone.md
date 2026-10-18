<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# Death Star - Execution Modes - ALONE

## Usage Recommendation

The ALONE mode has a higher implementation complexity compared to other modes, but it offers full customization, closely resembling a pure Infrastructure as Code (IaC) setup using native Terraform.

It is recommended only for high-complexity projects where extensive customization is required—particularly regarding Terraform environment configurations.

All DeathStar modules can be easily instantiated and configured in a more customized manner compared to the AUTO mode.

ALONE mode is fully compatible with all DeathStar-developed DevSecOps pipelines.

## How to Use

Infrastructure can be provisioned entirely using Terraform files. However, it is strongly recommended to configure resources using .JSON files whenever possible—storing them under the infra directory. This approach ensures greater consistency with the structure and practices adopted in the other modes.

```
(...)
.
├── infra/
│ ├── gcp/                  # Google Cloud Platform infrastructure
│   └── self/               # SELF mode configuration reader (can be customized)
│       ├── [resource]/     # Resource-specific directory
│       └── ├── **/*.json   # Object-level configurations
│           └── *.json      # Main resource configuration
├── terraform/              # Main Terraform Path (Will be updated with the Death Star)
|   ├── config.tf           # Terraform Enviroment Config
|   ├── variables.tf        # Terraform Variables
|   └── *.tf                # Other Terraform Files
(...)
```

**Important**, all required Terraform files must be explicitly created, as they will not be automatically included during pipeline execution. Only the standard Terraform variables linked to the DevSecOps pipeline will be injected at runtime.

Terraform modules maintained by DeathStar can still be used as part of your setup. To do so, simply reference the correct Git repository in your configuration—for example:

```
module "examplo_module" {
    source                           = "./modules/gcp/bigquery""git::https://dev.azure.com/suzano/Nucleo_Digital/_git/sz-deathStar-infra//terraform/modules/gcp/bigquery?ref=v_0.1.3"
    source                           = "./modules/gcp/bigquery"
    # Module-specific variables
}
```

Source locally details:

```
"git::[AZURE_DEVOPS_REPO_LINK]//[MODULE_PATH]?ref=[BRANCH_VERSION]"

ex.: "git::https://dev.azure.com/suzano/Nucleo_Digital/_git/sz-deathStar-infra//terraform/modules/gcp/bigquery?ref=v_0.1.3"
```

For implementation examples and ready-to-use resources, visit the [DeathStar - Examples Repository](https://dev.azure.com/suzano/Nucleo_Digital/_git/sz-deathStar-example).
