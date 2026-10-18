# Terraform — deathstar-infra

## Visão geral

Esta pasta contém a infraestrutura como código em Terraform usada pelo projeto `deathstar-infra`. O layout inclui um conjunto de módulos reutilizáveis para recursos GCP em `modules/gcp/`, além de arquivos de configuração de nível superior que orquestram a criação dos recursos.

## Estrutura principal

- `config.tf` — configuração global e chamadas de módulos de nível superior.
- `variables.tf` — variáveis de entrada expostas pelo conjunto de configurações.
- `outputs.tf` — saídas expostas após a aplicação.
- `modules/` — coleção de módulos reutilizáveis (p. ex. `gcp/`, `rest_api/`, `utils/`).

## Pré-requisitos

- Terraform 1.3+ recomendado (ajuste conforme `required_version` nos módulos se necessário).
- Conta GCP configurada com permissões para criar os recursos usados (IAM, Cloud Run, VPC, etc.).
- Backend remoto para estado (recomendado: Google Cloud Storage).
- `gcloud` instalado e autenticado localmente para deploys interativos.

## Como usar

1. Inicialize o Terraform:

   terraform init \
    -backend-config="bucket=<your-tfstate-bucket>" \
    -backend-config="prefix=<path/to/state>"

2. Faça o planejamento com variáveis apropriadas:

   terraform plan -var-file="envs/dev.tfvars"

3. Aplique:

   terraform apply -var-file="envs/dev.tfvars"

## Recomendações de estado e segurança

- Use um backend remoto (GCS) com controle de acesso restrito.
- Habilite locking (ex: backend do GCS com DynamoDB não se aplica; GCS já bloqueia via object generation, usar Cloud Storage + Terraform remote state locking se necessário).
- Não versionar credenciais em repositório. Utilize Secrets Manager ou Azure KeyVault para CI.

## Lista de módulos e arquivos importantes

No nível raiz existem vários arquivos `gcp_*.tf` que implementam conjuntos de recursos (por exemplo, `gcp_cloud_run.tf`, `gcp_vpc_network.tf`), além da pasta `modules/` com módulos detalhados. Consulte `modules/README.md` para a lista completa e instruções de cada módulo.

## Contribuindo

- Siga as convenções de nomenclatura das variáveis e outputs presentes em `variables.tf` e `outputs.tf`.
- Adicione testes mínimos (plan validation) para novos módulos.
- Atualize a documentação do módulo em `modules/<module>/README.md` quando fizer mudanças.

## Links úteis

- README dos módulos: `modules/README.md`
- Módulos GCP: `modules/gcp/README.md`
