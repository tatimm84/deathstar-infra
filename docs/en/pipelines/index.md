<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# Pipelines (CI / automation)

Short: Overview and developer guide for the `pipelines/` folder, containing reusable CI/CD YAMLs, helper scripts and validation templates.

## Where to find the code

- Pipeline definitions and helpers: `pipelines/`
- Key items:
  - `pipelines/default.yaml` — default infra pipeline
  - `pipelines/docs_advanced.yaml` — docs-focused pipeline
  - `pipelines/pyproject.toml` — packaging/dev extras for the pipeline helpers
  - `pipelines/src/` — Python helpers (CLI scripts)
  - `pipelines/build/` — prebuilt artifacts and wheels
  - `pipelines/build_validation/` — validation pipeline YAMLs
  - `pipelines/templates/` — reusable YAML templates/snippets

## How the folder is used

The `pipelines/` folder provides:

- Reusable pipeline definitions for CI (linting, testing, security scans, docs build/publish).
- Helper scripts used by pipelines (installable via `pip install -e pipelines/`).
- Prebuilt artifacts for quick CI bootstrap or local testing.
- Validation templates that can be included in a repository CI for quality gates.

## Quick developer workflows

1. Inspect a pipeline job

Open the YAML (for example `pipelines/default.yaml`) to inspect triggers, parameters, variables and the templates it includes.

2. Run helpers locally

```bash
python -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -e pipelines/
python pipelines/src/docs_infra.py --help
```

3. Preview docs (if the repo uses mkdocs)

```bash
mkdocs serve
```

## Templates and validation

- Use `pipelines/templates/` to compose or reuse steps across multiple repositories.
- Use YAMLs in `pipelines/build_validation/` to add validation stages to PR pipelines.

## Notes

- Keep scripts idempotent and supporting a `--dry-run` flag where possible.
- Avoid hardcoding environment secrets in templates; pass secrets via CI variables or secret store integrations.
- If you encounter long path problems on Windows, enable git long paths (`git config core.longpaths true`) or use WSL.
