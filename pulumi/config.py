"""
Provider configuration for Pulumi.
Converted from Terraform config.tf
"""

from typing import Any, cast

from pulumi_gcp.organizations import get_client_config
from variables import GCP_REGION

# Configure GCP provider (implicit through pulumi-gcp)
# Project and region are set via Pulumi config
# Get GCP client config for access token
client_config = cast(Any, get_client_config)()

# Docker provider configuration
# Note: Pulumi Docker provider configuration is typically done in __main__.py
# when creating docker.Provider resource if needed
docker_registry_config = {
    "address": f"{GCP_REGION}-docker.pkg.dev",
    "username": "oauth2accesstoken",
    "password": client_config.access_token,
}

# Export access token for use in other modules
access_token = client_config.access_token
