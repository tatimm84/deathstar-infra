# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

"""
Main Pulumi program - Entry point for infrastructure deployment.
Orchestrates all GCP infrastructure components.
"""

from components.dli import create_dli_resources
from components.gcp_api_services import create_api_services
from components.gcp_artifact_registry import create_artifact_registry
from components.gcp_bigquery import create_bigquery
from components.gcp_cloud_functions import create_cloud_functions
from components.gcp_cloud_identity import create_cloud_identity
from components.gcp_cloud_nat import create_cloud_nat
from components.gcp_cloud_run import create_cloud_run
from components.gcp_cloud_scheduler import create_cloud_scheduler
from components.gcp_composer import create_composer_environments
from components.gcp_compute_engine import create_compute_instances
from components.gcp_dataflow import create_dataflow_jobs
from components.gcp_dataform import create_dataform
from components.gcp_eventarc import create_eventarc_triggers
from components.gcp_firestore import create_firestore
from components.gcp_gke import create_gke_clusters
from components.gcp_iam import create_iam
from components.gcp_load_balancing import create_load_balancing
from components.gcp_pubsub import create_pubsub
from components.gcp_secret_manager import create_secret_manager
from components.gcp_service_account import create_service_account
from components.gcp_sql import create_sql
from components.gcp_ssl_security import create_ssl_security
from components.gcp_storage import create_storage
from components.gcp_tasks import create_tasks
from components.gcp_vpc_network import create_vpc_network
from components.gcp_workflows import create_workflows
from modules.ml_models import generate_ml_model_configs
from utils.config_aggregator import merge_module_configs
from variables import get_template_vars

import pulumi

# Get template variables
template_vars = get_template_vars()

# ----------------------------------------------------------------
# Generate modules configs dynamically and merge them
# ----------------------------------------------------------------
ml_model_configs = generate_ml_model_configs(template_vars)

all_configs = merge_module_configs(
    [
        ml_model_configs,
        # etl_configs,
        # feature_configs,
    ]
)

# ----------------------------------------------------------------
# Phase 1: Foundation Services
# ----------------------------------------------------------------
# Enable GCP API Services (required by all other components)
api_services = create_api_services(template_vars)
pulumi.export("api_services_count", len(api_services["services"]))

# Create Service Account resources
service_accounts = create_service_account(
    template_vars=template_vars,
    opts=pulumi.ResourceOptions(depends_on=api_services["services"]),
    extra_json_files=all_configs.get("service_accounts", []),
)
pulumi.export("service_accounts_count", len(service_accounts["service_accounts"]))

# Create IAM resources
iam = create_iam(
    template_vars=template_vars,
    opts=pulumi.ResourceOptions(depends_on=api_services["services"]),
    extra_json_files=all_configs.get("iams", []),
)
pulumi.export("iam_count", len(iam["iams"]))

# Create Cloud Identity groups and memberships
cloud_identity = create_cloud_identity(
    template_vars=template_vars,
    opts=pulumi.ResourceOptions(depends_on=api_services["services"]),
    # extra_json_files=all_configs.get("cloud_identity", []),
)
pulumi.export("cloud_identity_groups_count", len(cloud_identity["groups"]))
pulumi.export(
    "cloud_identity_memberships_count",
    len(cloud_identity["memberships"]),
)

# ----------------------------------------------------------------
# Phase 2: Core Infrastructure
# ----------------------------------------------------------------
# Create Secret Manager secrets
secret_manager = create_secret_manager(
    template_vars=template_vars,
    opts=pulumi.ResourceOptions(depends_on=api_services["services"]),
    # extra_json_files=all_configs.get("secret_manager", [])
)
pulumi.export("secret_manager_secrets_count", len(secret_manager["secrets"]))

# Create Artifact Registry (for Docker images)
artifact_registry = create_artifact_registry(
    template_vars=template_vars,
    opts=pulumi.ResourceOptions(depends_on=api_services["services"]),
    extra_json_files=all_configs.get("artifact_registry", []),
)
pulumi.export(
    "artifact_registry_repos_count",
    len(artifact_registry["repositories"]),
)
pulumi.export(
    "artifact_registry_images_count",
    len(artifact_registry["images"]),
)

# Create Pub/Sub topics and subscriptions
pubsub = create_pubsub(
    template_vars=template_vars,
    opts=pulumi.ResourceOptions(depends_on=api_services["services"]),
    # extra_json_files=all_configs.get("pubsub", [])
)
pulumi.export("pubsub_topics_count", len(pubsub["topics"]))
pulumi.export("pubsub_subscriptions_count", len(pubsub["subscriptions"]))

# ----------------------------------------------------------------
# Phase 3: Security and Networking
# ----------------------------------------------------------------
# Create VPC Network (foundation for networking)
vpc_network_resources = create_vpc_network(
    template_vars=template_vars,
    opts=pulumi.ResourceOptions(depends_on=api_services["services"]),
    # extra_json_files=all_configs.get("vpc_network", [])
)
pulumi.export("vpc_network_addresses_count", len(vpc_network_resources["addresses"]))
pulumi.export("vpc_network_networks_count", len(vpc_network_resources["networks"]))
pulumi.export(
    "vpc_network_subnetworks_count", len(vpc_network_resources["subnetworks"])
)
pulumi.export(
    "vpc_network_firewall_rules_count",
    len(vpc_network_resources["firewall_rules"]),
)

# Create SSL Security (certificates, policies, Cloud Armor)
ssl_security = create_ssl_security(
    template_vars=template_vars,
    opts=pulumi.ResourceOptions(
        depends_on=api_services["services"]
        + vpc_network_resources["addresses"]
        + vpc_network_resources["networks"]
        + vpc_network_resources["subnetworks"]
    ),
    # extra_json_files=all_configs.get("ssl_security", [])
)
pulumi.export("ssl_armor_policies_count", len(ssl_security["armor_policies"]))
pulumi.export("ssl_certificates_count", len(ssl_security["certificates"]))
pulumi.export("ssl_policies_count", len(ssl_security["policies"]))

# Create Cloud NAT (NAT Gateway and Router)
cloud_nat = create_cloud_nat(
    template_vars=template_vars,
    opts=pulumi.ResourceOptions(
        depends_on=api_services["services"]
        + vpc_network_resources["addresses"]
        + vpc_network_resources["networks"]
        + vpc_network_resources["subnetworks"]
    ),
    # extra_json_files=all_configs.get("cloud_nat", [])
)
pulumi.export("cloud_nat_routers_count", len(cloud_nat["routers"]))
pulumi.export("cloud_nat_gateways_count", len(cloud_nat["nats"]))

# ----------------------------------------------------------------
# Phase 4: Storage & Databases
# ----------------------------------------------------------------
# Create Cloud Storage buckets
storage = create_storage(
    template_vars=template_vars,
    opts=pulumi.ResourceOptions(depends_on=api_services["services"]),
    extra_json_files=all_configs.get("storages", []),
)
pulumi.export("storage_buckets_count", len(storage["buckets"]))
pulumi.export("storage_objects_count", len(storage["objects"]))

# Create BigQuery datasets and tables
bigquery = create_bigquery(
    template_vars=template_vars,
    opts=pulumi.ResourceOptions(depends_on=api_services["services"]),
    # extra_json_files=all_configs.get("bigquery", []),
)
pulumi.export("bigquery_datasets_count", len(bigquery["datasets"]))
pulumi.export("bigquery_tables_count", len(bigquery["tables"]))
pulumi.export("bigquery_routines_count", len(bigquery["routines"]))

# Create Firestore databases
firestore = create_firestore(
    template_vars=template_vars,
    opts=pulumi.ResourceOptions(depends_on=api_services["services"]),
    # extra_json_files=all_configs.get("firestore", []),
)
pulumi.export("firestore_databases_count", len(firestore["databases"]))

# Create Cloud SQL (managed databases)
sql = create_sql(
    template_vars=template_vars,
    opts=pulumi.ResourceOptions(
        depends_on=api_services["services"]
        + vpc_network_resources["addresses"]
        + vpc_network_resources["networks"]
        + vpc_network_resources["subnetworks"]
    ),
    # extra_json_files=all_configs.get("sql", []),
)
pulumi.export("sql_instances_count", len(sql["instances"]))
pulumi.export("sql_databases_count", len(sql["databases"]))

# ----------------------------------------------------------------
# Phase 5: Compute Services & Container Orchestration
# ----------------------------------------------------------------
# Create Cloud Functions (depends on VPC and Artifact Registry)
cloud_functions = create_cloud_functions(
    template_vars=template_vars,
    opts=pulumi.ResourceOptions(
        depends_on=api_services["services"]
        + artifact_registry["repositories"]
        + artifact_registry["images"]
        + vpc_network_resources["addresses"]
        + vpc_network_resources["networks"]
        + vpc_network_resources["subnetworks"]
    ),
    # extra_json_files=all_configs.get("cloud_functions", []),
)
pulumi.export("cloud_functions_count", len(cloud_functions["functions"]))

# Create Cloud Run (depends on Artifact Registry)
cloud_run = create_cloud_run(
    template_vars=template_vars,
    opts=pulumi.ResourceOptions(
        depends_on=api_services["services"]
        + artifact_registry["repositories"]
        + artifact_registry["images"]
    ),
    extra_json_files=all_configs.get("cloud_runs", []),
)
pulumi.export("cloud_run_services_count", len(cloud_run["services"]))
pulumi.export("cloud_run_jobs_count", len(cloud_run["jobs"]))

# Create Compute Engine instances
compute_engine = create_compute_instances(
    template_vars=template_vars,
    opts=pulumi.ResourceOptions(
        depends_on=vpc_network_resources["addresses"]
        + vpc_network_resources["networks"]
        + vpc_network_resources["subnetworks"]
    ),
    # extra_json_files=all_configs.get("compute_engine", []),
)
pulumi.export("compute_instances_count", len(compute_engine["instances"]))
pulumi.export("compute_policies_count", len(compute_engine["policies"]))
pulumi.export("compute_attachments_count", len(compute_engine["attachments"]))

# Create GKE clusters and node pools
gke = create_gke_clusters(
    template_vars=template_vars,
    opts=pulumi.ResourceOptions(
        depends_on=vpc_network_resources["addresses"]
        + vpc_network_resources["networks"]
        + vpc_network_resources["subnetworks"]
    ),
    # extra_json_files=all_configs.get("gke", []),
)
pulumi.export("gke_clusters_count", len(gke["clusters"]))
pulumi.export("gke_node_pools_count", len(gke["node_pools"]))

# ----------------------------------------------------------------
# Phase 6: Data Orchestration and Processing
# ----------------------------------------------------------------
# Create Cloud Scheduler jobs (depends on Cloud Run and Functions)
cloud_scheduler = create_cloud_scheduler(
    template_vars=template_vars,
    opts=pulumi.ResourceOptions(
        depends_on=cloud_run["services"]
        + cloud_run["jobs"]
        + cloud_functions["functions"]
    ),
    extra_json_files=all_configs.get("cloud_schedulers", []),
)
pulumi.export("cloud_scheduler_jobs_count", len(cloud_scheduler["jobs"]))

# Create Workflows
workflows = create_workflows(
    template_vars=template_vars,
    opts=pulumi.ResourceOptions(depends_on=api_services["services"]),
    # extra_json_files=all_configs.get("workflows", []),
)
pulumi.export("workflows_count", len(workflows["workflows"]))

# Create Eventarc triggers
eventarc = create_eventarc_triggers(
    template_vars=template_vars,
    opts=pulumi.ResourceOptions(
        depends_on=cloud_run["services"] + cloud_run["jobs"] + storage["buckets"]
    ),
    # extra_json_files=all_configs.get("eventarc", []),
)
pulumi.export("eventarc_triggers_count", len(eventarc["triggers"]))

# Create Composer environments
composer = create_composer_environments(
    template_vars=template_vars,
    opts=pulumi.ResourceOptions(
        depends_on=vpc_network_resources["addresses"]
        + vpc_network_resources["networks"]
        + vpc_network_resources["subnetworks"]
    ),
    # extra_json_files=all_configs.get("composer", []),
)
pulumi.export("composer_environments_count", len(composer["composers"]))

# Create Dataflow jobs
dataflow = create_dataflow_jobs(
    template_vars=template_vars,
    opts=pulumi.ResourceOptions(depends_on=api_services["services"]),
    # extra_json_files=all_configs.get("dataflow", []),
)
pulumi.export("dataflow_jobs_count", len(dataflow["jobs"]))

# Create Dataform repositories, release configs, workflow configs and IAM
dataform = create_dataform(
    template_vars=template_vars,
    opts=pulumi.ResourceOptions(depends_on=api_services["services"]),
    # extra_json_files=all_configs.get("dataform", []),
)
pulumi.export("dataform_repositories_count", len(dataform["repositories"]))
pulumi.export("dataform_release_configs_count", len(dataform["release_configs"]))
pulumi.export("dataform_workflow_configs_count", len(dataform["workflow_configs"]))

# Create DLI resources
dli = create_dli_resources(
    template_vars=template_vars,
    opts=pulumi.ResourceOptions(depends_on=storage["buckets"]),
    # extra_json_files=all_configs.get("dli", []),
)
pulumi.export("dli_pipelines_count", len(dli["pipelines"]))
pulumi.export("dli_connectors_count", len(dli["connectors"]))
pulumi.export("dli_secrets_count", len(dli["secrets"]))

# ----------------------------------------------------------------
# Phase 6: Load Balancing
# ----------------------------------------------------------------
# Create Load Balancing (depends on SSL, Cloud Run, Cloud Functions)
load_balancing = create_load_balancing(
    template_vars=template_vars,
    opts=pulumi.ResourceOptions(
        depends_on=ssl_security["certificates"]
        + cloud_run["services"]
        + cloud_run["jobs"]
        + cloud_functions["functions"]
        + compute_engine["instances"]
        + vpc_network_resources["addresses"]
        + vpc_network_resources["networks"]
        + vpc_network_resources["subnetworks"]
    ),
    # extra_json_files=all_configs.get("load_balancing", []),
)
pulumi.export(
    "load_balancing_health_checks_count", len(load_balancing["health_checks"])
)
pulumi.export(
    "load_balancing_instance_groups_count", len(load_balancing["instance_groups"])
)
pulumi.export("load_balancing_negs_count", len(load_balancing["negs"]))
pulumi.export(
    "load_balancing_backend_services_count", len(load_balancing["backend_services"])
)
pulumi.export("load_balancing_url_maps_count", len(load_balancing["url_maps"]))
pulumi.export("load_balancing_proxies_count", len(load_balancing["proxies"]))
pulumi.export(
    "load_balancing_forwarding_rules_count", len(load_balancing["forwarding_rules"])
)

# ----------------------------------------------------------------
# Phase 7: Additional Services
# ----------------------------------------------------------------
# Create Cloud Tasks queues
tasks = create_tasks(
    template_vars=template_vars,
    opts=pulumi.ResourceOptions(depends_on=api_services["services"]),
    # extra_json_files=all_configs.get("tasks", []),
)
pulumi.export("tasks_queues_count", len(tasks["queues"]))

# ----------------------------------------------------------------
# Summary
# ----------------------------------------------------------------
total_components_created = (
    len(api_services["services"])
    + len(service_accounts["service_accounts"])
    + len(iam["iams"])
    + len(cloud_identity["groups"])
    + len(cloud_identity["memberships"])
    + len(secret_manager["secrets"])
    + len(artifact_registry["repositories"])
    + len(artifact_registry["images"])
    + len(pubsub["topics"])
    + len(pubsub["subscriptions"])
    + len(vpc_network_resources["addresses"])
    + len(vpc_network_resources["networks"])
    + len(vpc_network_resources["subnetworks"])
    + len(vpc_network_resources["firewall_rules"])
    + len(ssl_security["armor_policies"])
    + len(ssl_security["certificates"])
    + len(ssl_security["policies"])
    + len(cloud_nat["routers"])
    + len(cloud_nat["nats"])
    + len(storage["buckets"])
    + len(storage["objects"])
    + len(bigquery["datasets"])
    + len(bigquery["tables"])
    + len(bigquery["routines"])
    + len(firestore["databases"])
    + len(sql["instances"])
    + len(sql["databases"])
    + len(cloud_functions["functions"])
    + len(cloud_run["services"])
    + len(cloud_run["jobs"])
    + len(compute_engine["instances"])
    + len(compute_engine["policies"])
    + len(compute_engine["attachments"])
    + len(gke["clusters"])
    + len(gke["node_pools"])
    + len(cloud_scheduler["jobs"])
    + len(workflows["workflows"])
    + len(eventarc["triggers"])
    + len(composer["composers"])
    + len(dataflow["jobs"])
    + len(dataform["repositories"])
    + len(dataform["release_configs"])
    + len(dataform["workflow_configs"])
    + len(dli["pipelines"])
    + len(dli["connectors"])
    + len(dli["secrets"])
    + len(load_balancing.get("forwarding_rules", []))
    + len(load_balancing.get("backend_services", []))
    + len(load_balancing.get("health_checks", []))
    + len(load_balancing.get("negs", []))
    + len(tasks.get("queues", []))
)
pulumi.export("total_components_created", total_components_created)
