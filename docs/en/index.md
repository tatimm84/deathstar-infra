<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# DeathStar Infrastructure Documentation

Welcome to the DeathStar Infrastructure documentation. This documentation provides an overview of the project, its components, and how to use the Terraform resources effectively.

## Table of Contents

1. [Introduction](#introduction)
2. [Getting Started](#getting-started)
3. [Contributing](#contributing)
4. [License](#license)

## Introduction

The DeathStar Infrastructure project aims to automate the creation and management of infrastructure using Terraform. This project leverages Google Cloud Platform (GCP) resources to provide a scalable and efficient infrastructure setup.
The Git subrepositories format is a more modern approach than Git submodules, as it doesn't require a .gitmodules file and can be split off into their own standalone repositories at any time.

## Getting Started

To get started with the DeathStar Infrastructure project, follow these steps:

1. Clone the repository
   Command if you already added deathstar as a submodule of your repository:
   ```
   git clone --recurse-submodules https://your-repo-url.git
   ```
   Command if you didn't added deathstar as a submodule of your repository:
   ```
   git clone https://your-repo-url.git
   ```

2.Add deathstar as a submodule of your repository:

```
git submodule add --force -b v_0.4.0 https://suzano@dev.azure.com/suzano/Nucleo_Digital/_git/sz-deathStar-infra
git submodule init
git submodule sync          # Synchronizes the submodule's remote URL in local git config
git submodule update --remote # Updates the submodule to the latest commit on the tracked branch
```

2. Ensure you have Terraform installed. You can download it from the [Terraform website](https://www.terraform.io/downloads.html).
   Or Ensure you have Pulumi installed. You can download it from the [Pulumi website](https://www.pulumi.com/docs/get-started/download-install/).

3. Configure your GCP credentials and set up the necessary permissions.

4. Initialize and preview changes:
   Terraform:
   ```
   cd sz-deathStar-infra/terraform
   terraform init
   terraform plan # Preview changes
   terraform apply # Apply changes
   ```
   Pulumi:
   ```
   cd sz-deathStar-infra/pulumi
   pulumi preview # Preview changes
   pulumi up # Apply changes
   ```

## Shortcuts

Quick links to frequently-used docs and developer tasks:

- Pipelines overview: `docs/pipelines/index.md`
- Default pipeline details: `docs/pipelines/default.md`
- Docs advanced pipeline: `docs/pipelines/docs_advanced.md`
- Pipelines helpers (scripts): `docs/pipelines/src.md`
- Pipeline templates: `docs/pipelines/templates.md`
- Pipeline validations: `docs/pipelines/build_validation.md`
- Terraform GCP modules index: `docs/terraform/gcp/index.md`
- Terraform module docs: `docs/terraform/gcp/*.md` (browse the folder)
- Repository README: `../README.md`

Additional repository docs:

- Getting Started: `docs/getting_started.md`
- Development guide: `docs/development.md`
- Terraform overview: `docs/terraform_overview.md`
- Pipelines documentation: `docs/pipelines/index.md`
- Contributing: `docs/contributing.md`
- Licenses: `docs/licenses.md`
- Changelog: `docs/changelog.md`
- Repository TODO: `docs/todo.md`

## Developer shortcuts (commands)

Run common developer checks from the repository root:

```bash
# Install bootstrap tools (Windows: run in Git Bash as admin)
bash ./bootstrap_precommit.sh

# Run all pre-commit hooks locally
pre-commit run --all-files

# Build documentation site (if using mkdocs)
mkdocs build --config-file docs/docs/mkdocs.yml

# Quick Terraform checks
terraform -chdir=terraform fmt
terraform -chdir=terraform validate
```

## Troubleshooting tips

- Git on Windows: If you see "Filename too long" errors, enable long paths in Git:

```bash
git config core.longpaths true
```

- If pre-commit hooks fail due to environment issues, re-run the bootstrap script and then:

```bash
pre-commit clean
pre-commit run --all-files
```

## Contributing

Contributions to the DeathStar Infrastructure project are welcome! Please follow the guidelines in the `README.md` file for contributing to the project.

## License

This project is licensed under the MIT License. See the `LICENSE` file for more details.
