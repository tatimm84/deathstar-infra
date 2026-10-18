<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# GCP modules

This page lists the GCP modules available in `terraform/modules/gcp/` and links to their documentation under `docs/terraform/gcp/`.

Each module page contains a short description, example usage, and tables documenting input variables and outputs (when present).

Available modules

- [apis_services](apis_services.md) — Enable GCP APIs
- [artifact_registry](artifact_registry.md) — Artifact Registry repositories and images
- [bigquery](bigquery.md) — BigQuery datasets and tables
- [cloud_functions](cloud_functions.md) — Cloud Functions (Gen1/Gen2)
- [cloud_identity](cloud_identity.md) — Cloud Identity groups and memberships
- [cloud_load_balancing](cloud_load_balancing.md) — Load balancers, proxies, URL maps
- [cloud_nat_gateway](cloud_nat_gateway.md) — Cloud Router & Cloud NAT
- [cloud_run](cloud_run.md) — Cloud Run v2 services and jobs
- [cloud_scheduler](cloud_scheduler.md) — Cloud Scheduler jobs
- [cloud_storage](cloud_storage.md) — Cloud Storage buckets & objects
- [composer](composer.md) — Cloud Composer environments
- [compute_engine](compute_engine.md) — Compute Engine instances
- [dataflow](dataflow.md) — Dataflow jobs
- [dataproc](dataproc.md) — Dataproc clusters
- [eventarc](eventarc.md) — Eventarc triggers
- [firestore](firestore.md) — Firestore databases and documents
- [gcloud](gcloud.md) — gcloud helper operations
- [iam](iam.md) — IAM and service accounts
- [k8s_engine](k8s_engine.md) — GKE clusters
- [pubsub](pubsub.md) — Pub/Sub topics and subscriptions
- [redis](redis.md) — Memorystore Redis
- [secret_manager](secret_manager.md) — Secret Manager
- [sql_database](sql_database.md) — Cloud SQL instances/databases
- [ssl_security](ssl_security.md) — Certificates, SSL policies, Cloud Armor
- [vpc_network](vpc_network.md) — VPCs, subnets, firewalls
- [workflows](workflows.md) — Google Workflows

If a module is missing a Variables or Outputs table it may not declare inputs/outputs or needs manual documentation — open the module's `variables.tf`/`outputs.tf` under `terraform/modules/gcp/<module>/` for authoritative details.

Choose a module from the list above or browse the `docs/terraform/gcp/` folder.
