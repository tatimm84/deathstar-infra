<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# Development guide

Short: How to develop, run linters, formatters and tests locally.

## Set up a virtual environment and install developer extras

```bash
python -m venv .venv
source .venv/bin/activate    # bash / macOS
# Windows PowerShell: .\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
python -m pip install -e pipelines/    # installs pipeline helpers and dev extras
```

## Pre-commit and formatting

```bash
# Ensure pre-commit hooks are installed (bootstrap does this as well)
pre-commit install

# Run fixes where possible
pre-commit run --all-files
```

## SQL linting caveat

- If `sqlfluff` fails during pre-commit hook creation with a Click/option incompatibility, ensure the `.pre-commit-config.yaml` pins a compatible `sqlfluff` rev. For local troubleshooting, try:

```bash
pre-commit clean
pre-commit run --all-files
```

## Working with Terraform

- Use the Terraform wrapper in `pipelines/templates/terraform_w_vars.yaml` as a reference for CI behavior.
- Locally prefer running `terraform -chdir=terraform init/plan/apply` to experiment.

## Running docs generation locally

```bash
python -m pip install -e pipelines/
python pipelines/src/docs_infra.py --help
mkdocs serve -f docs/mkdocs.yml
```
