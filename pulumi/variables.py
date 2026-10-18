"""
Configuration variables for the Pulumi infrastructure.
"""

from utils.json_reader import calculate_directory_hash

import pulumi

# --------------------------------------------------------------------
# Environment, UID_NOW
# --------------------------------------------------------------------
config = pulumi.Config()

ENVIRONMENT = config.require("ENVIRONMENT")
UID_NOW = config.require("UID_NOW")

# --------------------------------------------------------------------
# Resources Variables - Azure Devops
# --------------------------------------------------------------------
AZURE_DEVOPS_REPO = config.require("AZURE_DEVOPS_REPO")

# --------------------------------------------------------------------
# Resources Variables - CLOUD SQL
# --------------------------------------------------------------------
SQL_USER_PW = config.get_secret("SQL_USER_PW") if config.get("SQL_USER_PW") else None

# --------------------------------------------------------------------
# Resources Variables - GCP Project
# --------------------------------------------------------------------
gcp_config = pulumi.Config("gcp")
GCP_PROJECT = gcp_config.require("project")
PROJECT_NUMBER = config.require("PROJECT_NUMBER")
GCP_REGION = gcp_config.get("region") or "us-central1"

# --------------------------------------------------------------------
# Resources Variables - Terraform/Pulumi
# --------------------------------------------------------------------
SRC_CODE_PATH = config.get("SRC_CODE_PATH") or "../src"
SRC_DOCS_PATH = config.get("SRC_DOCS_PATH") or "../docs"
SRC_INFRA_PATH = config.get("SRC_INFRA_PATH") or "../infra"
RUNNING_SERVICE_ACCOUNT = config.get("RUNNING_SERVICE_ACCOUNT") or ""

# --------------------------------------------------------------------
# Data Lake Ingestion
# --------------------------------------------------------------------
DLI_COMPOSER_BUCKET = config.get("DLI_COMPOSER_BUCKET") or ""
DLI_COMPOSER_DAG_PATH = config.get("DLI_COMPOSER_DAG_PATH") or ""
DLI_DATAINTEGRATOR_BUCKET = config.get("DLI_DATAINTEGRATOR_BUCKET") or ""
DLI_DATAINTEGRATOR_PATH = config.get("DLI_DATAINTEGRATOR_PATH") or ""


# Template variables dictionary (equivalent to Terraform locals)
def get_template_vars() -> dict:
    """
    Returns template variables dictionary for string substitution.

    Args:

    Returns:
        Dictionary of template variables
    """
    return {
        "__project_number__": PROJECT_NUMBER,
        "__project_name__": GCP_PROJECT,
        "__region__": GCP_REGION,
        "__env__": ENVIRONMENT,
        "__uid_now__": UID_NOW,
        "__infra__": SRC_INFRA_PATH,
        "__source__": SRC_CODE_PATH,
        "__doc__": SRC_DOCS_PATH,
        "__running_service_account__": RUNNING_SERVICE_ACCOUNT,
        "__sha1__": calculate_directory_hash(SRC_CODE_PATH),
    }
