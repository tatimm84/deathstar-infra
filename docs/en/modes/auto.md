<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# Death Star - Execution Modes - AUTO

## Usage Recommendation

The AUTO mode is designed to streamline project initialization. It is ideal for low to medium complexity projects where the required infrastructure resources are pre-approved and already implemented within the DeathStar platform.

This mode is not recommended for scenarios involving extensive customization—particularly those that require managing interdependencies within the same module. For such cases, consider using the SELF mode, which offers greater flexibility and control.

AUTO mode is fully compatible with all DeathStar-developed DevSecOps pipelines.

## How to Use

Infrastructure provisioning is defined using .JSON files and managed by DeathStar’s standard Terraform resources. To use AUTO mode, simply structure your configurations following the directory layout below:

```
(...)
.
├── infra/
│ ├── gcp/                  # Google Cloud Platform infrastructure
│   └── auto/               # AUTO mode configuration reader
│       └── [resource]/     # Resource-specific directory
│           ├── **/*.json   # Object-level configurations
│           └── *.json      # Main resource configuration
(...)
```

**Important**, no terraform file is needed.

For implementation examples and ready-to-use resources, visit the [DeathStar - Examples Repository](https://dev.azure.com/suzano/Nucleo_Digital/_git/sz-deathStar-example?path=/infra/gcp/auto).
