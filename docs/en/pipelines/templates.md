# Pipeline templates (`pipelines/templates`)

Short: Reusable YAML snippets and templates that are included by the main pipeline definitions. Templates encapsulate common jobs (docs build, terraform flow, cost checks, publishing) so they can be reused across repositories.

## Location

- `pipelines/templates/`

## Files and purpose

- `docs.yaml` — Template that builds infrastructure documentation (uses `pipelines/src/docs_infra.py`), runs mkdocs, and synchronizes the generated site to a GCS bucket.
- `terraform_w_vars.yaml` — Terraform pipeline template that defines environment variable resolution, secure files download, terraform init/plan/apply and optional debug artifacts. This template is referenced by `pipelines/default.yaml`.
- `infracost.yaml` — Template to run Infracost checks and report cost diffs (used for FinOps checks).
- `lib_publish.yaml` — Template to publish built libraries or artifacts (wheels, packages) to a package registry.
- `repo_to_vectordb.yaml` — Template to run the `repo_to_vectordb` job that extracts repo content and pushes vectors into a vector DB (Vertex AI / BigQuery).
- `secure_file.yaml` — Small template helper for downloading and handling secure files (service accounts, certificates) in pipeline jobs.

## How to include a template

Reference a template inside a pipeline using the `template:` syntax and pass required parameters. Example (as used in `pipelines/default.yaml`):

```yaml
stages:
  - template: pipelines/templates/terraform_w_vars.yaml@deathstar-infra
    parameters:
      deathstar_mode: auto
      project_version: v1
      project_prefix: deathstar-example
      TF_VAR_ENVIRONMENT: dev
      TF_VAR_GCP_REGION: us-central1
```

## Notes and recommendations

- Keep templates generic and configurable via parameters.
- Avoid placing secrets in templates; pass secret names or secure file identifiers and let the CI download them securely.
- Add clear parameter documentation in the top of each template so consumers know what to pass.
