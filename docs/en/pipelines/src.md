<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# Pipeline helpers (scripts in `pipelines/src`)

Short: Python helper scripts and small utilities used by pipelines to validate repository structure, generate documentation, enforce PR flow rules, and export repository content to a vector database.

## Location

- `pipelines/src/`

## Files and a short description

- `docs_infra.py` — Generates Markdown documentation from JSON artifacts and templates. Key features:
  - Scans folders for JSON definitions, applies optional Jinja2 templating, and writes formatted Markdown files.
  - Helpers for formatting dictionaries, lists and SQL view content into Markdown tables and code blocks.
  - Typical invocation (pipeline): `python pipelines/src/docs_infra.py` (the docs template in `pipelines/templates/docs.yaml` calls it).

- `pr_flow.py` — PR flow validator that enforces branch naming, allowed target branches and merge rules.
  - Validates source and target branch names and exits with non-zero status on failures (suitable for CI).
  - Example local usage:

```bash
python pipelines/src/pr_flow.py -source feature/my-feature -target develop
```

- `repo_structure.py` — Repository structure validator.
  - Checks for required files/folders (e.g., `.pre-commit-config.yaml`, `docs/`, `infra/`, `pipelines/`, `src/`).
  - Detects forbidden patterns (e.g., `.venv`, `__pycache__`, `build/`) and reports errors as CI log issues.
  - Example usage:

```bash
python pipelines/src/repo_structure.py -source .
```

- `repo_to_vectordb.py` — Exports repository contents to a BigQuery-based vector DB for downstream retrieval/AI workflows.
  - Loads files, optionally templates JSON files, splits documents into chunks and inserts vectors into BigQuery using Vertex AI embeddings.
  - Requires service account credentials for BigQuery and Vertex AI; mostly used in organization-level docs/AI pipelines.
  - Example invocation (pipeline): the `docs_advanced` pipeline or a dedicated job runs this script with `-file_path`, `-repository`, `-bq_table` and credentials flags.

- `validate_commit.sh` — Small shell helper used to bootstrap or validate local pre-commit configuration (invoked in some CI setups).

## How to run locally

1. Create and activate a virtual environment, then install the pipelines package (optional):

```bash
python -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -e pipelines/
```

2. Run a script with `--help` to see flags. Example:

```bash
python pipelines/src/docs_infra.py --help
python pipelines/src/pr_flow.py --help
```

## Developer notes

- Scripts are written to be executed inside CI and will return non-zero exit codes on validation failures so that pipeline jobs fail fast.
- Prefer to run lighter validations (PR flow, repo structure) on PRs and heavier tasks (vector DB ingestion) on scheduled jobs or merges.
