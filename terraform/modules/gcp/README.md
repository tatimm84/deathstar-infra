<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# Módulos GCP

Pasta: `modules/gcp/`

Esta coleção contém módulos que encapsulam recursos e padrões comuns em Google Cloud Platform.

## Submódulos disponíveis

- `apis_services/` — Habilita APIs GCP necessárias (Cloud Run, Pub/Sub, etc.).
- `artifact_registry/` — Gerencia repositórios Artifact Registry (Docker/OCI).
- `bigquery/` — Recursos de BigQuery (datasets, tabelas).
- `cloud_functions/` — Deploy de Cloud Functions.
- `cloud_identity/` — Configurações relacionadas ao Cloud Identity.
- `cloud_load_balancing/` — Load balancers HTTP(S) e TCP.
- `cloud_nat_gateway/` — Cloud NAT e rotas associadas.
- `cloud_run/` — Cria serviços Cloud Run (container-based serverless).
- `cloud_scheduler/` — Jobs agendados no Cloud Scheduler.
- `cloud_storage/` — Buckets e políticas de armazenamento.
- `composer/` — Environments Composer (Airflow).
- `compute_engine/` — Instâncias e grupos de VM.
- `dataflow/` — Pipelines Dataflow e templates.
- `dataproc/` — Clusters Dataproc.
- `eventarc/` — Configuração de Eventarc.
- `firestore/` — Firestore DB resources.
- `gcloud/` — Helpers para comandos gcloud (scripts provisionamento).
- `iam/` — Papéis e bindings IAM reutilizáveis.
- `k8s_engine/` — GKE clusters e node pools.
- `pubsub/` — Tópicos e assinaturas Pub/Sub.
- `redis/` — Memorystore Redis.
- `secret_manager/` — Segredos e versões no Secret Manager.
- `sql_database/` — Cloud SQL instances/databases.
- `ssl_security/` — Recursos e configurações relacionados a certificados/SSL.
- `vpc_network/` — VPCs, sub-redes e regras de firewall.
- `workflows/` — Workflows GCP.

## Exemplo de uso (Cloud Run)

```hcl
module "my_cloud_run" {
  source = "../../modules/gcp/cloud_run"

  project_id = var.project_id
  name       = "my-service"
  image      = "gcr.io/${var.project_id}/my-service:latest"
  region     = var.region
  # outros inputs conforme o módulo
}
```

## Como navegar nos módulos

Cada submódulo tende a ter seus próprios `main.tf`, `variables.tf`, `outputs.tf` e possivelmente um `README.md` com detalhes. Abra a pasta do submódulo para ver as variáveis exigidas e outputs.
