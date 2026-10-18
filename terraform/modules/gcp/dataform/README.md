<!--
SPDX-FileCopyrightText: 2025 Suzano S.A.

SPDX-License-Identifier: MIT
-->

# dataform

## Descrição

Módulo para criação de repositórios Dataform no GCP, incluindo configurações de release e workflow.

O Dataform é um serviço que permite transformar dados brutos em tabelas bem definidas no BigQuery usando SQL e JavaScript.

## Recursos

Este módulo cria os seguintes recursos:

- `google_dataform_repository` - Repositório Dataform
- `google_dataform_repository_release_config` - Configuração de release
- `google_dataform_repository_workflow_config` - Configuração de workflow
- `google_dataform_repository_iam_member` - Membros IAM do repositório

## Uso

### Repositório básico com Git remoto (HTTPS)

```hcl
module "dataform" {
  source      = "../../modules/gcp/dataform"
  gcp_project = var.project_id
  gcp_region  = "southamerica-east1"
  name        = "my-dataform-repo"

  git_remote_settings = {
    url                                 = "https://github.com/my-org/my-repo.git"
    default_branch                      = "main"
    authentication_token_secret_version = "projects/my-project/secrets/github-token/versions/latest"
  }
}
```

### Repositório com SSH

```hcl
module "dataform" {
  source      = "../../modules/gcp/dataform"
  gcp_project = var.project_id
  gcp_region  = "southamerica-east1"
  name        = "my-dataform-repo"

  git_remote_settings = {
    url            = "git@github.com:my-org/my-repo.git"
    default_branch = "main"
    ssh_authentication_config = {
      user_private_key_secret_version = "projects/my-project/secrets/ssh-key/versions/latest"
      host_public_key                 = "github.com ssh-rsa AAAA..."
    }
  }
}
```

### Repositório completo com Release e Workflow Config

```hcl
module "dataform" {
  source      = "../../modules/gcp/dataform"
  gcp_project = var.project_id
  gcp_region  = "southamerica-east1"
  name        = "my-dataform-repo"

  git_remote_settings = {
    url                                 = "https://github.com/my-org/my-repo.git"
    default_branch                      = "main"
    authentication_token_secret_version = "projects/my-project/secrets/github-token/versions/latest"
  }

  release_config_create = true
  release_config_name   = "production"
  git_commitish         = "main"
  cron_schedule         = "0 8 * * *"

  code_compilation_config = {
    default_database = "my-project"
    default_schema   = "dataform"
    default_location = "US"
  }

  workflow_config_create   = true
  workflow_config_name     = "daily-run"
  workflow_cron_schedule   = "0 9 * * *"
  workflow_service_account = "dataform-sa@my-project.iam.gserviceaccount.com"

  invocation_config = {
    included_tags                   = ["daily"]
    transitive_dependencies_included = true
  }
}
```

Ver detalhes em `variables.tf`.
