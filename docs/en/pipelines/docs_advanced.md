<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# Pipeline: docs_advanced

Short: Advanced documentation pipeline that builds, validates and optionally publishes documentation and integrates repository extraction (e.g., `repo_to_vectordb`).

## Location

- `pipelines/docs_advanced.yaml`
- Template referenced: `pipelines/templates/docs.yaml` (remote ref `@sz-deathStar-infra`)

## Triggers

- Branches: `master`, `release`, `develop`
- Watched paths (example): `pipelines/docs_advanced.yaml`, `docs/*`, `infra/*`

## Parameters and variables

- `project_prefix` (string) — default `sz-snop` — prefix applied to generated artifacts
- `TF_VAR_ENVIRONMENT` — environment variable derived from branch name (same mapping as the default pipeline)
- `SEND_TO_SNOP_BUCKET` (boolean, default: `false`) — controls whether to send artifacts to SNOP bucket

## Stages / flow

- template: `pipelines/templates/docs.yaml@sz-deathStar-infra`
  - parameters passed:
    - `project_prefix`
    - `TF_VAR_ENVIRONMENT`

## Typical jobs you will find in docs pipelines

- `docs:build` — build the site (mkdocs or SSG) and package artifacts
- `docs:validate` — check links, linting and doc rules (link-check, spell-check, md-lint)
- `docs:publish` — publish artifacts to a target (storage bucket, GH Pages, etc.)
- `repo_to_vectordb` — optional job that extracts repository content and pushes vectors to a DB using `pipelines/src/repo_to_vectordb.py`
- `data_lineage` / `data_docs` — jobs that extract dataset metadata / lineage and add it to documentation

## Run locally (developer)

1. Install dev extras and helpers:

```bash
python -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -e pipelines/
```

2. Run docs validations locally, for example:

```bash
python pipelines/src/docs_infra.py validate --path docs/
```

3. Preview the site (if using mkdocs):

```bash
mkdocs serve
```

## Notes

- This pipeline helps ensure documentation quality before publishing.
- It is typically triggered on PRs that change `docs/*` or `infra/*`.
