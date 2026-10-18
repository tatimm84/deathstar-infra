# Pulumi Infrastructure

This directory contains the Pulumi infrastructure code for `sz-deathStar-infra`.

## Quick Start

### Using uv

```bash
# Install dependencies
uv sync

# Configure stack
pulumi stack init dev
pulumi config set gcp:project your-project-id
pulumi config set gcp:region southamerica-east1

# Preview changes
pulumi preview

# Deploy
pulumi up
```

## Directory Structure

```
pulumi/
├── Pulumi.yaml         # Project configuration
├── pyproject.toml      # Python project & dependencies (uv)
├── requirements.txt    # Python dependencies (pip - legacy)
├── __main__.py        # Main entry point
├── config.py          # GCP provider configuration
├── variables.py       # Configuration variables
├── components/        # GCP service components
│   ├── api_services.py
│   ├── cloud_storage.py
│   ├── cloud_run.py
│   ├── iam.py
│   ├── bigquery.py
│   └── ... (26 total modules)
└── utils/             # Utility modules
    └── json_reader.py
```

## Components

Each component module manages a specific GCP service:

- **api_services.py** - Enable GCP APIs
- **cloud_storage.py** - Cloud Storage buckets
- **cloud_run.py** - Cloud Run services
- **cloud_functions.py** - Cloud Functions
- **cloud_scheduler.py** - Cloud Scheduler jobs
- **iam.py** - IAM roles and service accounts
- **bigquery.py** - BigQuery datasets and tables
- **vpc_network.py** - VPC networks and subnets
- **secret_manager.py** - Secret Manager secrets
- **pubsub.py** - Pub/Sub topics and subscriptions
- And 16 more...

## Configuration

Configuration is managed through:

1. **Pulumi config** - Stack-specific values
2. **JSON files** - Located in `../infra/gcp/auto/`
3. **Environment variables** - `PULUMI_VAR_*` prefix

See [README_PULUMI.md](../README_PULUMI.md) for detailed configuration instructions.

## CI/CD

This infrastructure is deployed via Azure DevOps pipeline:

```yaml
extends:
  template: pipelines/templates/pulumi_w_vars.yaml@sz-deathStar-infra
  parameters:
    deathstar_mode: auto
    PULUMI_VAR_ENVIRONMENT: prod
    pulumi_stack: prod
```

See [PULUMI_PIPELINE_USAGE.md](../pipelines/templates/PULUMI_PIPELINE_USAGE.md) for pipeline documentation.

## Development

### Local Development

**With uv (Recommended)**:

```bash
cd pulumi/

# Install dependencies (creates .venv automatically)
uv sync

# Run preview
pulumi preview

# Deploy to dev
pulumi up
```

**With pip (Legacy)**:

```bash
cd pulumi/

# Install dependencies
pip install -r requirements.txt

# Run preview
pulumi preview
```

### Adding New Components

1. Create new component file in `components/`
2. Import in `__main__.py`
3. Add JSON configuration in `../infra/gcp/auto/`
4. Test locally with `pulumi preview`

### Testing

```bash
# Validate configuration
pulumi config

# Preview without deploying
pulumi preview --diff

# Export stack state
pulumi stack export > stack.json
```

## Documentation

- [Main Pulumi README](../README_PULUMI.md) - Complete guide
- [Pipeline Usage](../pipelines/templates/PULUMI_PIPELINE_USAGE.md) - CI/CD documentation
- [Pulumi Docs](https://www.pulumi.com/docs/) - Official documentation
- [GCP Provider](https://www.pulumi.com/registry/packages/gcp/) - GCP resources

## Support

For issues or questions, contact the infrastructure team.
