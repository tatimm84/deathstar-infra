# Build validation (CI quality gates)

Short: A collection of pipeline YAMLs used as validation checks and quality gates that can be included in PR branch policies or run as standalone jobs.

## Location

- `pipelines/build_validation/`

## Files included

- `val_advanced_security.yaml` — advanced security validation jobs (static analysis, infra security checks).
- `val_bright.yaml` — lightweight validation flow used for fast feedback (short CI checks).
- `val_changelog.yaml` — validates changelog presence and format for releases.
- `val_code_quality_security.yaml` — combined code-quality and security validations (linters, dependency checks).
- `val_pr_flow.yaml` — PR flow validation (verifies branch naming and allowed merges using `pipelines/src/pr_flow.py`).
- `val_repo_structure.yaml` — repository structure validation (ensures required files and folders are present).
- `val_sonarcloud.yaml` — SonarCloud integration job template for code quality metrics.

## How these files are used

- Include one or more of these YAMLs in your CI pipeline definition or reference them in branch policies so PRs must pass the selected validations before merging.
- Example (run `val_pr_flow` as part of PR validation):

```yaml
# Example: include val_pr_flow.yaml in your PR validation pipeline
trigger: none
stages:
  - template: pipelines/build_validation/val_pr_flow.yaml@deathstar-infra
    parameters:
      python_version: 3.13
```

## Notes and recommendations

- Use `val_pr_flow.yaml` to verify PR branch semantics (it runs `pipelines/src/pr_flow.py` with system PR variables).
- Use `val_repo_structure.yaml` to automatically enforce repository layout and required files.
- Prefer smaller/fast checks in the main PR pipeline and run heavier security or SonarCloud scans as scheduled or on a merge-to-main job to reduce PR latency.
