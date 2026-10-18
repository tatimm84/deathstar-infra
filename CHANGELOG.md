<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# Changelog

Todas as alterações notáveis neste projeto serão documentadas neste arquivo.

## 0.4.1 - 19 Agosto 2026

### FEATURE:

    - pulumi/components/gcp_bigquery.py
        - Mantém apenas aliases completos com dataset_id+table_id para tables e routines

### BUGFIX

    - pulumi/components/gcp_cloud_functions.py
        - Adiciona generation ao build_config para permitir o build de novas versoes.


## 0.4.0 - 09 Dezembro 2025

### FEATURE:

    - Adição de todos os módulos de pulumi

## 0.3.16 - 01 Dezembro 2025

### FEATURE:

    - pipelines/templates/terraform_w_vars.yaml:
        - Adicionado parâmetro build_service_account para customizar SA de execução do pipeline
        - Adicionado parâmetro TF_VAR_RUNNING_SERVICE_ACCOUNT para customizar SA de runtime dos recursos GCP
    - terraform/variables.tf:
        - Nova variável RUNNING_SERVICE_ACCOUNT para service account de runtime dos recursos
    - terraform/gcp_bigquery.tf, gcp_cloud_function.tf, gcp_cloud_run.tf, gcp_cloud_scheduler.tf:
        - Adicionada template variable __running_service_account__ para substituição em JSONs
    - terraform/modules/gcp/cloud_functions/variables.tf:
        - Adicionada variável RUNNING_SERVICE_ACCOUNT no módulo
    - terraform/modules/gcp/cloud_run/variables.tf:
        - Adicionada variável RUNNING_SERVICE_ACCOUNT no módulo
    - terraform/modules/gcp/cloud_scheduler/variables.tf:
        - Adicionada variável RUNNING_SERVICE_ACCOUNT no módulo

## 0.3.14 - 28 Novembro 2025

### FEATURE:

    - pipelines/templates/docs.yaml:
        - Adicionada possibilidade de direcionar os docs buildados para buckets do snop
        - Adicionado parametro SEND_TO_SNOP_BUCKET
        - Novas extensoes mkdocs no pyproject:
            - "mkdocs-mermaid2-plugin>=1.0,<2.0"
            - "mkdocstrings>=0.26,<1.0"
            - "mkdocstrings-python>=1.0,<2.0"

### FIX:

    - pipelines/templates/docs.yaml:
        - Ajustes nos caminhos e movimentacoes das pastas durante a pipe.

## 0.3.12 - 19 Novembro 2025

    - terraform/modules/gcp/cloud_load_balancing/main.tf
        - Fix LB Url Map Regional
    - terraform/modules/gcp/ssl_security
        - Add SSL Region

## 0.3.10 - 20 Outubro 2025

### FEATURE

    - /terraform/gcp_tasks.tf
        - Adiciona módulo para gerenciamento de filas Google Cloud Tasks
    - /terraform/modules/gcp/tasks/
        - main.tf - Criação de filas Cloud Tasks e configurações IAM
        - variables.tf - Variáveis do módulo (rate limits, retry config, logging)
        - outputs.tf - Outputs da fila criada
        - README.md - Documentação do módulo

## 0.3.9 - 07 Outubro 2025

### FEATURE

    - /terraform/dli.tf
        - adiciona modulo dli para Data Lake Ingestion
    - /gcp_bigquery.tf
        - permitir set de destination_dataset_id e destination_table_id

## 0.3.8 - 07 Outubro 2025

    - /terraform/gcp_cloud_function.tf
        - Poder passar o parametro 'gcp_region'
    - /terraform/gcp_load_balacing.tf
        - Poder passar o parametro 'gcp_region'
    - /terraform/gcp_cloud_run.tf
        - Poder passar o parametro 'gcp_region'
    - /terraform/gcp_cloud_scheduler.tf
        - Poder passar o parametro 'gcp_region'
    - /terraform/gcp_secret_manager.tf
        - Poder passar o parametro 'gcp_region'
    - /terraform/gcp_artifact_registry.tf
        - Poder passar o parametro 'gcp_region'

## 0.3.7 - 07 Outubro 2025

### FIX

    - /terraform/modules/gcp/artifact_registry/main.tf
        - adiciona ao variavel login_regions permitindo o login em mais de uma regiao.

## 0.3.6 - 03 Outubro 2025

### FIX

    - /terraform/modules/gcp/cloud_functions/main.tf
        - adiciona ao ZIP da function arquivos que não sofreram replacement.

## 0.3.4 - 30 Setembro 2025

### FIX

    - /terraform/modules/utils/reader/main.tf
        - Adicionar a função try para tratar erros de JSON inválido no módulo reader

## 0.3.3 - 24 Setembro 2025

### FEATURE

    - /terraform/gcp_cloud_function.tf
        - dar a possibilidade de passar variáveis de ambiente para replace nos arquivos de código fonte da cloud function
    - /terraform/modules/gcp/cloud_function/main.tf
        - adição de resource local_file para replace e mount do path da function antes do zip

## 0.3.1 - 23 Setembro 2025

### FEATURE

    - /terraform/modules/gcp/compute_engine/main.tf
        - Tirar Comentário de Merge
    - /terraform/gcp_artifact_registry.tf
        - incluir váriável __project_name__ no --build-args
    - terraform/gcp_cloud_storage.tf
        - dar a possibilidade de passar variáveis de ambiente para replace nos blobs que subiram para o storage

## 0.3.0 - 22 Setembro 2025

### FIX

    - GCP Cloud Loadbalancing host rules and patch matcher list
    - GCP Bigquery in Data Transfer with gcp_region and table with table_replication_info

### FEATURE

    - Adequação de todos os códigos para pre-commit atual (file hygiene; formatter for markdown, yaml and json; SPDX; trivy; terraform formater; dockerfile linter; python: linter formatter, security e licence compliance; node.js: linter security e licence check)
    - Transferindo pyproject.toml dentro de pipelines e usando ferramenta uv
    - Adição de bootstrap para instalação de pre-commit
    - Adição de ruff.toml com configurações do ruff
    - Criação de pipeline de infracost
    - Mudança do pipeline de terraform with vars com opção de debug e eliminação de pipeline terraform with vars debug
    - Remoção e adequação de pipelines de qualidade de código, segurança e de guadrails
    - Templatefile com padronização de variáveis principais (var.PROJECT_NUMBER,var.GCP_PROJECT, var.GCP_REGION, var.ENVIRONMENT,var.UID_NOW)
    - Terraform de Dataflow
    - Documentação completa

## 0.2.8 - 25 Agosto 2025

### FEATURE

    - Implementação do cloud composer 3

## 0.2.7 - 23 Julho 2025

### FIX

    - Corrigindo Connector em cenários que cria-se a subnetwork e não a network

## 0.2.6 - 23 Julho 2025

## 0.2.5 - 08 Agosto 2025

### FEATURE

    - /terraform/gcp_bigquery.tf
        - Adição do placeholder "__project_name__" como parametro de replace nos .sql e .json;
        - Adequação do recurso google_bigquery_routine, para arguments_config ser aceito como string.
    - /terraform/modules/gcp/bigquery/variables.tf
        - tipagem arguments_config.
    - /terraform/gcp_cloud_function.tf
        - Adição dos placeholder "__project_number__", "__env__", "__uid_now__" e "__project_name__" cmo parametro para replace nos .json;
    - /terraform/gcp_cloud_run.tf
        - Adição do placeholder "__project_name__" como parametro de replace nos .sql e .json;
    - /terraform/gcp_firestore.tf
        - Possibilitar a parametrização do campo: "document_fields" como json.
    - /terraform/gcp_iam.tf
        - Adição dos placeholder "__project_number__", "__env__", "__uid_now__" e "__project_name__" cmo parametro para replace nos .json;
    - /terraform/gcp_secret_manager.tf
        - Possibilitar a parametrização do campo: "secret_data" como json.

## 0.2.4 - 23 Julho 2025

### FEATURE

    - Adicionado o template "__project_name__" em todos os fluxos
        -  "__project_name__" é o gcp_project, oque permite parametrização

## 0.2.3 - 11 Julho 2025

### FEATURE

    - BigQuery:
        - Routine
            - Criação de Recurso para Criação de Procedure
    - VPC Network:
        - Poder passar o parametro 'gcp_region'

## 0.2.1 - 01 Julho 2025

### FEATURE

    - BigQuery:
        - Materialized view
            - Adicionada variavel materialized_view_query
            - Adicionado fluxo para ler a query
            - Permite omitir o schema (null) quando o json definir uma materialized view

## 0.1.2 - 10 Abril 2024

### FIX

    - Permitir definir nome de Dataset e Tabela internamente no JSON

## 0.1.1 - 10 Abril 2024

### FEATURE

    - Adicionado modulo de PubSub

### FIX

    - Corrigindo Function Gen2

## 0.0.3 - 05 Setembro 2024

### FEATURE

    - Atualização de versões terraform ">= 1.9.0" e hashicorp/google 5.25.0
    - Correção de reursos conforme nova versão e para ser templatefile

## 0.0.2 - 08 Abril 2024

### FEATURE

    - Atualização de versões terraform ">= 1.9.0" e hashicorp/google 5.25.0

## 0.0.1 - 05 Setembro 2023

### FEATURE

    - Versão inicial do repositório
