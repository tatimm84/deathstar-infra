# Death Star - Execution Modes - SELF

## Usage Recommendation

The SELF mode offers simple implementation and enables the creation of resources equivalent to those in AUTO mode, with the added flexibility of defining specific .tf files.

It is best suited for medium-complexity projects that utilize approved and pre-developed resources, but that also require greater configurability—whether due to module interdependencies or the need for custom variables.

All DeathStar modules can be easily instantiated and configured in a more customized manner compared to the AUTO mode.

SELF mode is fully compatible with all DeathStar-developed DevSecOps pipelines.

## How to Use

Infrastructure provisioning is defined using .JSON files and managed by DeathStar’s standard Terraform resources. To use AUTO mode, simply structure your configurations following the directory layout below:

```
(...)
.
├── infra/
│ ├── gcp/                  # Google Cloud Platform infrastructure
│   ├── auto/               # AUTO mode configuration reader
│       ├── [resource]/     # Resource-specific directory
│       └── ├── **/*.json   # Object-level configurations
│           └── *.json      # Main resource configuration
│   └── self/               # SELF mode configuration reader (can be customized)
│       ├── [resource]/     # Resource-specific directory
│       └── ├── **/*.json   # Object-level configurations
│           └── *.json      # Main resource configuration
├── terraform/              # Main Terraform Path (Will be updated with the Death Star)
|   └── self_*.tf           # SELF Terraform Files
(...)
```

**Important**, only the additional Terraform files need to be defined manually. All standard DeathStar modules and their configurations will be automatically included in the Terraform path when the pipeline is executed.
