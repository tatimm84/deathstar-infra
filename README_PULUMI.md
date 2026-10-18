# SPDX-FileCopyrightText: 2025 Suzano S.A.

# SPDX-License-Identifier: MIT

# Pulumi Infrastructure - sz-deathStar-infra

This directory contains the Pulumi version of the sz-deathStar-infra infrastructure, converted from Terraform.

## Overview

The Pulumi infrastructure is written in Python and provides the same functionality as the Terraform version, with the following benefits:

- Type-safe infrastructure as code
- Better IDE support and refactoring capabilities
- Improved testing capabilities
- Native Python programming constructs

## Prerequisites

1. **Python 3.8+** installed
2. **Pulumi CLI** installed ([installation guide](https://www.pulumi.com/docs/get-started/install/))
3. **GCP credentials** configured
4. **Docker Desktop** (for building container images)

## Installation

1. **Install Pulumi CLI**:

   ```bash
   # Windows (using Chocolatey)
   choco install pulumi

   # Or download from https://www.pulumi.com/docs/get-started/install/
   ```

2. **Install Python dependencies**:

   **Using uv (Recommended - 10-100x faster)**:

   ```bash
   cd c:\Users\t.machado\Downloads\Projetos\sz-deathStar-infra\pulumi

   # Install uv if not already installed
   # Windows (PowerShell)
   powershell -c "irm https://astral.sh/uv/install.ps1 | iex"

   # Install dependencies
   uv sync
   ```

   **Using pip (Legacy)**:

   ```bash
   cd c:\Users\t.machado\Downloads\Projetos\sz-deathStar-infra\pulumi
   pip install -r requirements.txt
   ```

3. **Configure GCP credentials**:
   ```bash
   gcloud auth application-default login
   ```

## Configuration

### Create a Pulumi Stack

If any password required, this is the name of the gcp_project, like for example sz-workspace-digital-feat

```bash
pulumi login <IAC_BUCKET_NAME> # example: gs://sz-terraform-333608256663

# Select stack or Create a new stack (e.g., dev, staging, prod)
pulumi stack select <REPO_NAME> || pulumi stack init <REPO_NAME> #example: sz-gurobi-service

# Configure GCP project
pulumi config set gcp:project <GCP_PROJECT> # example: sz-workspace-digital-feat
pulumi config set gcp:region <GCP_REGION> # example: us-central1

# Obter access token curto da SA para usar como senha no Artifact Registry
gcloud auth activate-service-account --key-file=$(serviceAccount.secureFilePath)
TOKEN_SA="$(gcloud auth print-access-token)"
pulumi config set ci:TOKEN_SA "${TOKEN_SA}" --secret
pulumi config get ci:TOKEN_SA >/dev/null || { echo "TOKEN_SA não setado"; exit 1; }

# Set required configuration
pulumi config set ENVIRONMENT <ENV> # example: feat
pulumi config set UID_NOW $(date +%Y%m%d%H%M)
pulumi config set AZURE_DEVOPS_REPO <REPO_NAME> # example: sz-gurobi-service
pulumi config set PROJECT_NUMBER <PROJECT_NUMBER> # example: 333608256663

# Set optional configuration
pulumi config set SRC_CODE_PATH ../../src
pulumi config set SRC_DOCS_PATH ../../docs
pulumi config set SRC_INFRA_PATH ../../infra

# Set secrets (encrypted)
pulumi config set --secret PULUMI_CONFIG_PASSPHRASE <GCP_PROJECT> # example: sz-workspace-digital-feat
pulumi config set --secret SQL_USER_PW your-password
```

### Configuration File

Alternatively, create a `Pulumi.dev.yaml` file:

```yaml
config:
  gcp:project: sz-snop-dev
  gcp:region: southamerica-east1
  sz-deathStar-infra:ENVIRONMENT: dev
  sz-deathStar-infra:UID_NOW: "202412081200"
  sz-deathStar-infra:AZURE_DEVOPS_REPO: sz-deathStar-example-feat
  sz-deathStar-infra:PROJECT_NUMBER: "1234567890"
  sz-deathStar-infra:SQL_USER_PW:
    secure: AAABAxxxx... # encrypted value
```

## Usage

### Preview Changes

```bash
pulumi preview
```

This shows what resources will be created/updated/deleted without making any changes.

### Deploy Infrastructure

```bash
pulumi up
```

Review the preview and confirm to deploy.

### Destroy Infrastructure

```bash
pulumi destroy
```

### View Outputs

```bash
pulumi stack output
```

### View Stack State

```bash
pulumi stack
```

## Project Structure

```
sz-deathStar-infra/
├── pulumi/                 # Pulumi infrastructure (NEW LOCATION)
│   ├── Pulumi.yaml         # Project configuration
│   ├── requirements.txt    # Python dependencies
│   ├── __main__.py         # Main entry point
│   ├── config.py           # Provider configuration
│   ├── variables.py        # Configuration variables
│   ├── components/         # GCP service components
│   │   ├── api_services.py
│   │   ├── cloud_storage.py
│   │   ├── cloud_run.py
│   │   ├── iam.py
│   │   ├── bigquery.py
│   │   ├── vpc_network.py
│   │   ├── secret_manager.py
│   │   ├── pubsub.py
│   │   ├── cloud_functions.py
│   │   ├── artifact_registry.py
│   │   ├── cloud_scheduler.py
│   │   └── ... (other services)
│   └── utils/              # Utility modules
│       └── json_reader.py  # JSON configuration reader
└── terraform/              # Terraform infrastructure (existing)
```

## JSON Configuration

The Pulumi version maintains compatibility with the existing JSON-based configuration system. Place your JSON configuration files in the `../infra/gcp/auto/` directory structure:

```
../infra/gcp/auto/
├── apis_services/
│   └── services.json
├── cloud_storage/
│   ├── bucket1.json
│   └── bucket2.json
├── cloud_run/
│   └── service1.json
└── ... (other services)
```

## Migration from Terraform

### State Migration

If you want to import existing Terraform-managed resources into Pulumi:

```bash
# Export Terraform state
cd terraform
terraform show -json > terraform-state.json

# Import resources into Pulumi
pulumi import gcp:storage/bucket:Bucket my-bucket my-bucket-name
```

### Running Both Systems

You can run Terraform and Pulumi side-by-side:

- Keep Terraform code in `terraform/` directory
- Keep Pulumi code in root directory
- Use different resource names to avoid conflicts

## Differences from Terraform

### Template Variables

**Terraform**:

```hcl
locals {
  template_vars = {
    "__env__" = var.ENVIRONMENT
  }
}
```

**Pulumi**:

```python
template_vars = get_template_vars(token_sa=access_token)
```

### Resource Creation

**Terraform**:

```hcl
resource "google_storage_bucket" "bucket" {
  name     = var.bucket
  location = var.gcp_region
}
```

**Pulumi**:

```python
bucket = gcp.storage.Bucket(
    "bucket",
    name=bucket_name,
    location=GCP_REGION,
)
```

### Dynamic Blocks

**Terraform**:

```hcl
dynamic "lifecycle_rule" {
  for_each = var.lifecycle_rule
  content {
    action { ... }
  }
}
```

**Pulumi**:

```python
lifecycle_rules=[
    gcp.storage.BucketLifecycleRuleArgs(
        action=...,
    )
    for rule in lifecycle_rules
] if lifecycle_rules else None
```

## CI/CD Integration

### Azure DevOps Pipeline

Update your pipeline to use Pulumi:

```yaml
steps:
  - task: UsePythonVersion@0
    inputs:
      versionSpec: "3.9"

  - script: |
      pip install -r requirements.txt
      pulumi login --cloud-url azblob://pulumi-state
      pulumi stack select $(ENVIRONMENT)
      pulumi preview
    displayName: "Pulumi Preview"

  - script: |
      pulumi up --yes
    displayName: "Pulumi Deploy"
    condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
```

## Troubleshooting

### Common Issues

1. **Import Error**: Ensure all dependencies are installed

   ```bash
   pip install -r requirements.txt
   ```

2. **GCP Authentication**: Verify credentials

   ```bash
   gcloud auth application-default login
   gcloud config set project YOUR_PROJECT_ID
   ```

3. **JSON Configuration Not Found**: Check `SRC_INFRA_PATH` configuration

   ```bash
   pulumi config set SRC_INFRA_PATH ../infra
   ```

4. **Docker Build Failures**: Ensure Docker Desktop is running

## Support

For issues or questions:

1. Check the [Pulumi GCP documentation](https://www.pulumi.com/registry/packages/gcp/)
2. Review the [implementation plan](C:\Users\t.machado.gemini\antigravity\brain\659df798-4eda-43d0-8e0a-f5b6c6173676\implementation_plan.md)
3. Contact the infrastructure team

## License

MIT License - See LICENSE file for details
