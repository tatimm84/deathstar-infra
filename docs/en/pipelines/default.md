<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# Pipeline: default

Short: Default infrastructure pipeline that sets triggers, project parameters and reuses the `terraform_w_vars` template for Terraform stages.

## Location

- `pipelines/default.yaml`
- Template referenced: `pipelines/templates/terraform_w_vars.yaml` (as a template reference `@sz-deathStar-infra`)

## Triggers

- Branches: `master`, `release`, `develop`
- Watched paths (example): `pipelines/default.yaml`, `terraform/*`, `src/*`

## Key parameters

- `deathstar_mode` (default: `auto`) — operational mode for templates
- `project_version` (default: `v1`) — project version suffix
- `project_prefix` (default: `sz-snop`) — resource name prefix
- `region` (default: `southamerica-east1`) — default GCP region
- `build_service_account` (default: `''`) — custom service account for pipeline execution (gcloud auth, terraform). If empty, uses `{project_prefix}-{environment}-account`
- `TF_VAR_RUNNING_SERVICE_ACCOUNT` (default: `''`) — custom service account for GCP resources runtime (Cloud Run, Functions, BigQuery, etc.). If empty, uses `{project}@appspot.gserviceaccount.com`

## Variables

- `TF_VAR_ENVIRONMENT` — derived from branch name (`master` → `prod`, `release` → `qas`, `develop` → `dev`)
- `TF_VAR_GCP_PROJECT` — computed as `${{ parameters.project_prefix }}-${{ variables.TF_VAR_ENVIRONMENT }}`
- `RUNNING_SERVICE_ACCOUNT` — service account used by GCP resources at runtime, configurable via `TF_VAR_RUNNING_SERVICE_ACCOUNT` parameter

## Stages / flow

This pipeline delegates the main work to a reusable template:

- template: `pipelines/templates/terraform_w_vars.yaml@sz-deathStar-infra`
  - parameters passed:
    - `deathstar_mode`, `project_version`, `project_prefix`, `TF_VAR_ENVIRONMENT`, `TF_VAR_GCP_REGION`
    - `build_service_account` — custom service account for pipeline build/deploy operations
    - `TF_VAR_RUNNING_SERVICE_ACCOUNT` — custom service account for GCP resources runtime
    - `secure_file_list` — list of secure files the pipeline may use (for example: certificates)

## Practical notes

- The file acts as a wrapper that defines triggers and environment variables and then reuses the terraform template that performs `init`, `validate`, `plan`, `apply` and other infra checks.

## Local testing

- Inspect `pipelines/templates/terraform_w_vars.yaml` to see the concrete jobs and steps.
- To run steps locally, execute the helper scripts referenced by the template (for example, the scripts in `pipelines/src/`) or run the Terraform commands manually with the same variables.

## Security note

- The pipeline uses `secure_file_list` for keys/certificates. Ensure proper secret management and rotation policies before using these files in production.

## Service Accounts

- **Service Account Customization**: Use `build_service_account` to specify a different service account for pipeline execution (useful for centralized authentication scenarios). Use `TF_VAR_RUNNING_SERVICE_ACCOUNT` to define which service account GCP resources will use at runtime (Cloud Run, Cloud Functions, BigQuery Data Transfer, etc.).
- **Template Variable**: Resources can reference `__running_service_account__` in JSON configuration files, which will be replaced with the actual service account email during Terraform template processing.

## Suggested next steps

- Document the template `terraform_w_vars.yaml` per job (init, validate, plan, apply, lint, tflint) under `docs/pipelines/templates/`.
- Review `secure_file_list` and integrate with your secret store or rotation process if needed.
