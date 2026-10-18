<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# Getting started

Short: Quick setup and first steps to bootstrap the project locally and run common checks.

## Prerequisites

- Git
- Python 3.10+ (used for helper scripts and pre-commit)
- Terraform (as indicated in `terraform/` files)
- Bash (Git Bash on Windows is supported)

## Bootstrap pre-commit and developer tools

This repository provides `bootstrap_precommit.sh` to install CLI tools and configure pre-commit hooks.

## Run (Git Bash / Linux / macOS):

```bash
# from repo root
bash ./bootstrap_precommit.sh
```

## Tips for Windows users

- Run `bootstrap_precommit.sh` from Git Bash with Administrator privileges when it needs to install system tools.
- If you hit long-path errors with Git, enable long paths:

```bash
git config core.longpaths true
```

## First checks

```bash
# Run all pre-commit hooks locally
pre-commit run --all-files

# Terraform basic checks
terraform -chdir=terraform fmt
terraform -chdir=terraform validate
```

## Where to go next

- Read the high-level docs: `docs/index.md`.
- See Terraform module documentation: `docs/terraform/gcp/index.md`.
- See pipeline docs: `docs/pipelines/index.md`.
