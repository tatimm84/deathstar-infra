# SPDX-FileCopyrightText: 2025 Suzano S.A.

#

# SPDX-License-Identifier: MIT

# Pulumi Pipeline Template - Usage Guide

This document describes how to use the Pulumi pipeline template (`pulumi_w_vars.yaml`) for deploying infrastructure with Pulumi in Azure DevOps.

## Overview

The `pulumi_w_vars.yaml` template provides a standardized way to deploy Pulumi infrastructure to GCP, following the same patterns as the existing Terraform pipeline. It supports:

- Multiple DeathStar modes (auto, self, alone)
- GCS backend for state storage
- Debug mode for preview-only runs
- Secure file and variable group integration
- Automatic GCP authentication and configuration

## Prerequisites

1. **GCP Service Account**: Secure file named `{project-name}-account` with GCP credentials
2. **GCS Bucket**: State storage bucket (automatically determined based on project version)
3. **Azure DevOps**: Repository resource for `sz-deathStar-infra`
4. **Pulumi Project**: Valid `Pulumi.yaml` and `requirements.txt` in repository root

## Parameters

### Required Parameters

| Parameter                | Type   | Description       | Example                  |
| ------------------------ | ------ | ----------------- | ------------------------ |
| `PULUMI_VAR_ENVIRONMENT` | string | Environment name  | `dev`, `staging`, `prod` |
| `pulumi_stack`           | string | Pulumi stack name | `dev`, `staging`, `prod` |

### Optional Parameters

| Parameter               | Type    | Default                | Description                             |
| ----------------------- | ------- | ---------------------- | --------------------------------------- |
| `debug`                 | boolean | `false`                | Run preview only (no deployment)        |
| `pulumi_version`        | string  | `3.100.0`              | Pulumi CLI version to install           |
| `deathstar_mode`        | string  | `auto`                 | Repository mounting mode                |
| `project_version`       | string  | `v2`                   | Project version (affects bucket naming) |
| `project_prefix`        | string  | `sz-workspace-digital` | GCP project prefix                      |
| `PULUMI_VAR_GCP_REGION` | string  | `southamerica-east1`   | GCP region                              |
| `secure_file_list`      | object  | `none`                 | List of secure files to download        |
| `group_var_secrets`     | object  | `none`                 | List of variable group secrets          |

## DeathStar Modes

### Auto Mode (Recommended)

Uses `sz-deathStar-infra` as base, adds current repo as overlay.

```yaml
parameters:
  deathstar_mode: auto
```

**Use when**: Your repository contains only infrastructure configuration (JSON files), and you want to use the shared Pulumi components from `sz-deathStar-infra`.

### Self Mode

Same as auto mode, but for the `sz-deathStar-infra` repository itself.

```yaml
parameters:
  deathstar_mode: self
```

**Use when**: Running the pipeline from the `sz-deathStar-infra` repository.

### Alone Mode

Uses current repo as base, adds `sz-deathStar-infra` components as dependencies.

```yaml
parameters:
  deathstar_mode: alone
```

**Use when**: Your repository has its own Pulumi code but needs shared components from `sz-deathStar-infra`.

## Usage Examples

### Example 1: Basic Production Deployment

```yaml
# azure-pipelines.yaml
trigger:
  branches:
    include:
      - main

resources:
  repositories:
    - repository: sz-deathStar-infra
      type: git
      name: Nucleo_Digital/sz-deathStar-infra

extends:
  template: pipelines/templates/pulumi_w_vars.yaml@sz-deathStar-infra
  parameters:
    deathstar_mode: auto
    PULUMI_VAR_ENVIRONMENT: prod
    pulumi_stack: prod
    PULUMI_VAR_GCP_REGION: southamerica-east1
```

### Example 2: Development with Debug Mode

```yaml
# azure-pipelines-dev.yaml
trigger:
  branches:
    include:
      - develop

resources:
  repositories:
    - repository: sz-deathStar-infra
      type: git
      name: Nucleo_Digital/sz-deathStar-infra

extends:
  template: pipelines/templates/pulumi_w_vars.yaml@sz-deathStar-infra
  parameters:
    debug: true # Preview only, no deployment
    deathstar_mode: auto
    PULUMI_VAR_ENVIRONMENT: dev
    pulumi_stack: dev
    pulumi_version: 3.100.0
```

### Example 3: With Secure Files and Secrets

```yaml
# azure-pipelines.yaml
trigger:
  branches:
    include:
      - main

resources:
  repositories:
    - repository: sz-deathStar-infra
      type: git
      name: Nucleo_Digital/sz-deathStar-infra

variables:
  - group: gcp-secrets # Variable group containing secrets

extends:
  template: pipelines/templates/pulumi_w_vars.yaml@sz-deathStar-infra
  parameters:
    deathstar_mode: auto
    PULUMI_VAR_ENVIRONMENT: prod
    pulumi_stack: prod
    secure_file_list:
      - my-secure-config.json
      - my-certificate.pem
    group_var_secrets:
      - SQL_USER_PW
      - API_KEY
```

### Example 4: Custom Pulumi Version

```yaml
# azure-pipelines.yaml
extends:
  template: pipelines/templates/pulumi_w_vars.yaml@sz-deathStar-infra
  parameters:
    pulumi_version: 3.95.0 # Use specific version
    PULUMI_VAR_ENVIRONMENT: staging
    pulumi_stack: staging
```

### Example 5: Multiple Environments

```yaml
# azure-pipelines.yaml
trigger: none # Manual trigger only

resources:
  repositories:
    - repository: sz-deathStar-infra
      type: git
      name: Nucleo_Digital/sz-deathStar-infra

stages:
  - template: pipelines/templates/pulumi_w_vars.yaml@sz-deathStar-infra
    parameters:
      deathstar_mode: auto
      PULUMI_VAR_ENVIRONMENT: dev
      pulumi_stack: dev
      debug: true # Preview for dev

  - template: pipelines/templates/pulumi_w_vars.yaml@sz-deathStar-infra
    parameters:
      deathstar_mode: auto
      PULUMI_VAR_ENVIRONMENT: staging
      pulumi_stack: staging
      debug: false # Deploy to staging
```

## Pipeline Stages

### Stage 1: DefineVars

1. Downloads GCP service account credentials
2. Authenticates with GCP
3. Retrieves GCP project number
4. Determines state bucket name
5. Generates unique timestamp (UID_NOW)
6. Exports variables for Pulumi stage

### Stage 2: Pulumi

1. Checks out repositories based on `deathstar_mode`
2. Downloads secure files (if specified)
3. Sets variable group secrets as environment variables
4. Installs Python 3.9 and dependencies
5. Installs Pulumi CLI
6. Logs into GCS backend
7. Selects/creates Pulumi stack
8. Configures Pulumi with environment variables
9. **Debug mode**: Runs `pulumi preview` and publishes artifacts
10. **Deploy mode**: Runs `pulumi up --yes`

## Environment Variables

The pipeline automatically sets the following Pulumi configuration values:

| Config Key          | Source                   | Description          |
| ------------------- | ------------------------ | -------------------- |
| `gcp:project`       | `PULUMI_VAR_GCP_PROJECT` | GCP project ID       |
| `gcp:region`        | `PULUMI_VAR_GCP_REGION`  | GCP region           |
| `ENVIRONMENT`       | `PULUMI_VAR_ENVIRONMENT` | Environment name     |
| `PROJECT_NUMBER`    | Auto-detected            | GCP project number   |
| `UID_NOW`           | Auto-generated           | Unique timestamp     |
| `AZURE_DEVOPS_REPO` | `Build.Repository.Name`  | Repository name      |
| `SRC_INFRA_PATH`    | Auto-set                 | Path to infra folder |

Additional secrets from `group_var_secrets` are set as `PULUMI_VAR_{SECRET_NAME}`.

## State Storage

The pipeline uses GCS (Google Cloud Storage) for Pulumi state:

- **Project v2**: `gs://sz-iac-{project-number}`
- **Project v1**: `gs://sz-pulumi-{project-number}`

The bucket is automatically determined based on the `project_version` parameter.

## Debug Mode

When `debug: true`:

- Runs `pulumi preview` instead of `pulumi up`
- Exports preview output as JSON
- Publishes preview artifacts to pipeline
- **Does not deploy** any infrastructure

Use debug mode for:

- Pull request validation
- Development testing
- Reviewing changes before deployment

## Troubleshooting

### Issue: "Stack not found"

**Solution**: The pipeline automatically creates the stack if it doesn't exist. Ensure `pulumi_stack` parameter matches your intended stack name.

### Issue: "Backend bucket not found"

**Solution**: Ensure the GCS bucket exists and the service account has access. The bucket name is determined by project version and project number.

### Issue: "Python dependencies failed to install"

**Solution**: Verify `requirements.txt` is in the repository root and contains valid package specifications.

### Issue: "Pulumi preview/up fails"

**Solution**: Check the pipeline logs for specific Pulumi errors. Common issues:

- Missing or incorrect configuration values
- GCP API permissions
- Resource conflicts

## Comparison with Terraform Pipeline

| Feature       | Terraform         | Pulumi                                 |
| ------------- | ----------------- | -------------------------------------- |
| CLI Tool      | `terraform`       | `pulumi`                               |
| State Backend | GCS with prefix   | GCS bucket root                        |
| Init Command  | `terraform init`  | `pulumi login` + `pulumi stack select` |
| Preview       | `terraform plan`  | `pulumi preview`                       |
| Deploy        | `terraform apply` | `pulumi up`                            |
| Config Vars   | `TF_VAR_*`        | `PULUMI_VAR_*` + `pulumi config set`   |
| Language      | HCL               | Python (in this case)                  |

## Best Practices

1. **Use debug mode for PR validation**: Set `debug: true` for pull request pipelines
2. **Pin Pulumi version**: Specify exact `pulumi_version` for reproducibility
3. **Separate stacks per environment**: Use different stack names for dev/staging/prod
4. **Store secrets in variable groups**: Never hardcode secrets in pipeline YAML
5. **Test in dev first**: Always validate changes in development before production
6. **Review preview output**: Check the preview artifacts before deploying

## Support

For issues or questions:

1. Check the [Pulumi documentation](https://www.pulumi.com/docs/)
2. Review the [sz-deathStar-infra README](../../README_PULUMI.md)
3. Contact the infrastructure team
