"""
ML MODELS MODULE.

This module dynamically provisions GCP resources for ML models
based on JSON configuration files stored in:
infra/gcp/auto/ml_model/<file_name.json>
Required structure:
{
    "artifact_repo": "ml-models",
    "image_path": "../src/dummy-service",
    "bucket_path": "sz-heimdall-${__env__}-conf/model-catalog",
    "bucket_config_content": {
        "model_version": "1.0.0",
        "owner": "risk-team",
        "description": "Fraud detection model",
        "features": ["amount", "location", "device"],
        "target": "is_fraud"
    },

    "cron_schedule": "0 * * * *",
    "labels": {
        "team": "risk"
    },

    "cloud_run_service": {
        "template": {
            "containers": [{
                "resources": {
                    "limits": {
                        "cpu": "1",
                        "memory": "512Mi"
                    }
                },
                "env": [{ "name": "ENV", "value": "dev" }]
            }]
        }
    }
}
"""

from __future__ import annotations

import sys
from typing import Any

from utils.json_reader import read_json_files, slugify
from variables import (
    AZURE_DEVOPS_REPO,
    ENVIRONMENT,
    GCP_PROJECT,
    GCP_REGION,
    PROJECT_NUMBER,
    SRC_INFRA_PATH,
)

import pulumi


def _build_sa_json(
    model_name: str,
    sa_account_id: str,
) -> dict[str, Any]:
    """Build the service account payload dictionary."""
    return {
        "source": f"service_account/{model_name}.json",
        "file_name": model_name,
        "file_name_extension": ".json",
        "path_type": "root",
        "content": {
            "account_id": sa_account_id,
            "description": f"Service Account for ML Model {model_name}",
            "display_name": f"SA for {model_name}",
        },
    }


def _build_iam_json(
    model_name: str,
    sa_account_id: str,
    project: str,
) -> dict[str, Any]:
    """Build the iam payload dictionary."""
    member = f"serviceAccount:{sa_account_id}@{project}.iam.gserviceaccount.com"
    return {
        "source": f"iam/{model_name}.json",
        "file_name": model_name,
        "file_name_extension": ".json",
        "path_type": "root",
        "content": {
            "type": "member",
            "project": project,
            "members": [member],
            "roles": [
                "roles/aiplatform.viewer",
                "roles/bigquery.dataEditor",
                "roles/bigquery.jobUser",
                "roles/bigquery.readSessionUser",
                "roles/run.invoker",
                "roles/cloudfunctions.invoker",
                "roles/storage.objectAdmin",
            ],
        },
    }


def _build_storage_json(
    model_name: str, bucket_path: str, content: dict[str, Any]
) -> dict[str, Any]:
    return {
        "source": f"cloud_storage/{bucket_path}/{model_name}.json",
        "file_name": model_name,
        "file_name_extension": ".json",
        "path_type": "subdir",
        "content": content,
    }


def _build_ar_json(
    model_name: str,
    artifact_repo: str,
    location: str,
    image_path: str,
    build_args: dict[str, str] | None = None,
) -> dict[str, Any]:
    """Build the artifact registry image payload dictionary."""
    if build_args is None:
        build_args = {}
    return {
        "source": f"artifact_registry/{artifact_repo}/{model_name}.json",
        "file_name": model_name,
        "file_name_extension": ".json",
        "path_type": "subdir",
        "content": {
            "location": location,
            "description": f"Artifact Registry Image for ML model {model_name}",
            "image_path": image_path,
            "build": {
                "args": build_args,
            },
        },
    }


def _build_crs_json(
    model_name: str,
    labels: dict[str, str],
    image_path: str,
    location: str,
    template: dict[str, Any],
) -> dict[str, Any]:
    """Build the Cloud Run Service payload dictionary."""

    return {
        "source": f"cloud_run/{model_name}.json",
        "file_name": model_name,
        "file_name_extension": ".json",
        "path_type": "root",
        "content": {
            "cloud_run_type": "service",
            "description": f"Cloud Run Service for ML Model {model_name}",
            "image_path": image_path,
            "ingress": "INGRESS_TRAFFIC_INTERNAL_ONLY",
            "labels": labels,
            "location": location,
            "template": template,
            "traffic": [{"percent": 100, "latest_revision": True}],
        },
    }


def _build_sched_json(
    model_name: str,
    cron_schedule: str,
    location: str,
    sa_account_id: str,
    project: str,
) -> dict[str, Any]:
    """Build the cloud scheduler payload dictionary."""
    sa_email = f"{sa_account_id}@{project}.iam.gserviceaccount.com"
    base_url = f"https://{model_name}-{PROJECT_NUMBER}.{location}.run.app"
    return {
        "source": f"cloud_scheduler/{model_name}.json",
        "file_name": model_name,
        "file_name_extension": ".json",
        "path_type": "root",
        "content": {
            "attempt_deadline": "30s",
            "description": f"Cloud Scheduler for ML Model {model_name}",
            "name": model_name,
            "location": location,
            "schedule": cron_schedule,
            "http_target": {
                "uri": f"{base_url}/run",
                "http_method": "POST",
                "headers": {
                    "Content-Type": "application/json",
                    "User-Agent": "Google-Cloud-Scheduler",
                },
                "oidc_token": {
                    "service_account_email": sa_email,
                    "audience": base_url,
                },
            },
        },
    }


MAX_MODEL_NAME_LENGTH = 27


def generate_ml_model_configs(
    template_vars: dict[str, str],
    json_files: list[dict[str, Any]] | None = None,
) -> dict[str, list[dict[str, Any]]]:
    """
    Generate ML Models resource configurations from JSON files.
    Resources configured: Service Accounts, Artifact Registry Images,
    Cloud Run Services, Config Objects in GCS, Cloud Scheduler.
    Files should be at root: infra/gcp/auto/ml_models/<any>.json

    Args:
        template_vars: Template variables for substitution
        json_files: Loaded JSON files list for local tests.
            If None, use read_json_files(...) from SRC_INFRA_PATH.

    Returns:
        Dictionary of resource configuration lists.
    """
    # 1) Read JSONs (with variable substitution)
    if json_files is None:
        files = read_json_files(
            source_path=f"{SRC_INFRA_PATH}/gcp/auto/ml_models/",
            files_regex="**",
            template_vars=template_vars,
        )
    else:
        files = json_files

    # 2) Validate files and generate configs
    sa_configs: list[dict[str, Any]] = []
    iam_configs: list[dict[str, Any]] = []
    stor_configs: list[dict[str, Any]] = []
    ar_configs: list[dict[str, Any]] = []
    crs_configs: list[dict[str, Any]] = []
    sched_configs: list[dict[str, Any]] = []

    for entry in files:
        content = entry.get("content", {}) or {}

        # 2.1) Validate files
        sys.stderr.write(f"INFO: Validating entries: {entry['source']}\n")
        model_name = content.get(
            "model_name", slugify(entry.get("file_name", "ml-model"))
        )
        if len(model_name) > MAX_MODEL_NAME_LENGTH:
            pulumi.log.error(
                f"Model name '{model_name}' is too long. Max "
                f"{MAX_MODEL_NAME_LENGTH} characters."
            )
            raise ValueError()

        # 2.2) Generate configs
        location = content.get("location", GCP_REGION)

        default_labels = {
            "managed-by": "pulumi",
            "environment": ENVIRONMENT,
            "repository": slugify(AZURE_DEVOPS_REPO)[:63],
            "model": model_name,
        }
        labels = dict(default_labels)
        labels.update(content.get("labels", {}))

        sa_account_id = f"sa-{model_name}"
        sa_email = f"{sa_account_id}@{GCP_PROJECT}.iam.gserviceaccount.com"
        artifact_repo = content.get("artifact_repo", "ml-models")
        image_path = content.get("image_path", "../src")
        docker_image_path = (
            f"{location}-docker.pkg.dev/{GCP_PROJECT}/"
            f"{artifact_repo}/{model_name}:latest"
        )

        sa_configs.append(
            _build_sa_json(
                model_name=model_name,
                sa_account_id=sa_account_id,
            )
        )

        iam_configs.append(
            _build_iam_json(
                model_name=model_name,
                sa_account_id=sa_account_id,
                project=GCP_PROJECT,
            )
        )

        stor_configs.append(
            _build_storage_json(
                model_name=model_name,
                bucket_path=content.get(
                    "bucket_path",
                    f"sz-heimdall-{ENVIRONMENT}-conf/model-catalog",
                ),
                content=content.get("bucket_config_content", {}),
            )
        )

        ar_configs.append(
            _build_ar_json(
                model_name=model_name,
                artifact_repo=artifact_repo,
                location=location,
                image_path=image_path,
                build_args=content.get("build_args"),
            )
        )

        cr_content = content.get("cloud_run_service", {})
        template = cr_content.get("template", {})
        template["service_account"] = sa_email
        template["containers"][0]["image"] = docker_image_path

        crs_configs.append(
            _build_crs_json(
                model_name=model_name,
                labels=labels,
                image_path=image_path,
                location=location,
                template=template,
            )
        )

        if "cron_schedule" in content:
            sched_configs.append(
                _build_sched_json(
                    model_name=model_name,
                    cron_schedule=content["cron_schedule"],
                    location=location,
                    sa_account_id=sa_account_id,
                    project=GCP_PROJECT,
                )
            )

    return {
        "service_accounts": sa_configs,
        "iams": iam_configs,
        "storages": stor_configs,
        "artifact_registry": ar_configs,
        "cloud_runs": crs_configs,
        "cloud_schedulers": sched_configs,
    }
