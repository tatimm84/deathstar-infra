# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

"""
GCP BigQuery component.
References:
https://www.pulumi.com/registry/packages/gcp/api-docs/bigquery/
"""

from __future__ import annotations

from collections import defaultdict, deque
import json
from typing import Any, cast

import pulumi_gcp as gcp
from utils.json_reader import (
    read_json_files,
    read_non_json_files,
    slugify,
)
from utils.schemas import (
    gcp_bigquery_data_transfer,
    gcp_bigquery_dataset,
    gcp_bigquery_routine,
    gcp_bigquery_table,
)
from utils.validations import validate_entries
from variables import ENVIRONMENT, GCP_PROJECT, GCP_REGION, SRC_INFRA_PATH

import pulumi


def _normalize_table_key(name: str, current_dataset: str) -> str:
    """
    Normaliza nomes de tabela em um formato canônico 'dataset/table'.
    Aceita:
      - 'table' -> assume o dataset corrente.
      - 'dataset/table' -> respeita o dataset informado.
    """
    name = name.replace("\\", "/").strip()
    if "/" in name:
        ds, tb = name.split("/", 1)
        return f"{ds.strip()}/{tb.strip()}"
    return f"{current_dataset}/{name}"


def _collect_table_nodes(files: list[dict[str, Any]]) -> dict[str, dict[str, Any]]:
    """
    Coleta as entradas de tabelas e monta um dicionário:
    key: 'dataset/table' ; value: entry
    """
    result: dict[str, dict[str, Any]] = {}
    for entry in files:
        if entry.get("path_type") != "subdir":
            continue
        content = entry.get("content", {}) or {}
        if not content.get("table_create", True):
            continue
        ds = _infer_dataset_id_from_entry(entry)
        if not ds:
            # Dataset não inferido; deixa para o fluxo normal avisar
            continue
        key = f"{ds}/{entry['file_name']}"
        result[key] = entry
    return result


def _build_table_graph(
    files: list[dict[str, Any]],
) -> tuple[dict[str, set[str]], dict[str, dict[str, Any]], set[str]]:
    """
    Constrói o grafo de dependências entre tabelas:
      - nodes: todas as tabelas presentes nos arquivos (table_create=True)
      - edges: dep -> table (quem é dependido aponta para quem depende)
    Retorna:
      graph, nodes_map, unknown_deps
    onde:
      - graph: dict[node] -> set(dependents)
      - nodes_map: 'dataset/table' -> entry
      - unknown_deps: dependências declaradas que não existem no lote
        (podem ser externas)
    """
    nodes_map = _collect_table_nodes(files)
    graph: dict[str, set[str]] = defaultdict(set)
    indegree: dict[str, int] = {k: 0 for k in nodes_map.keys()}
    unknown_deps: set[str] = set()

    for node_key, entry in nodes_map.items():
        content = entry.get("content", {}) or {}
        ds = _infer_dataset_id_from_entry(entry)
        depends = content.get("depends_on", []) or []
        for dep in depends:
            dep_key = _normalize_table_key(str(dep), str(ds or ""))
            # Se a dependência está no lote, criamos aresta dep -> node
            if dep_key in nodes_map:
                graph[dep_key].add(node_key)
                indegree[node_key] = indegree.get(node_key, 0) + 1
            else:
                # Dependência pode ser externa (tabela já existente)
                # — não bloqueia ordenação
                unknown_deps.add(dep_key)
                # Não aumenta indegree; apenas registramos para log posterior
                indegree.setdefault(node_key, 0)

        # Garante que o nó exista no grafo mesmo sem dependentes
        graph.setdefault(node_key, set())

    return graph, nodes_map, unknown_deps


def _toposort_tables(
    graph: dict[str, set[str]], nodes_map: dict[str, dict[str, Any]]
) -> list[dict[str, Any]]:
    """
    Ordena as tabelas por ordenação topológica (Kahn).
    Em caso de ciclo, lança ValueError com lista dos nós remanescentes.
    """
    # Calcula indegree
    indegree: dict[str, int] = {node: 0 for node in graph.keys()}
    for _u, v_set in graph.items():
        for v in v_set:
            indegree[v] = indegree.get(v, 0) + 1

    # Fila com nós sem dependências pendentes
    q = deque(sorted([n for n, d in indegree.items() if d == 0]))
    ordered_nodes: list[str] = []

    while q:
        u = q.popleft()
        ordered_nodes.append(u)
        for v in sorted(graph[u]):
            indegree[v] -= 1
            if indegree[v] == 0:
                q.append(v)

    if len(ordered_nodes) != len(graph):
        # Detectou ciclo
        remaining = [n for n, d in indegree.items() if d > 0]
        raise ValueError(
            "Foi detectado um ciclo de dependências entre tabelas: "
            + ", ".join(sorted(remaining))
        )

    # Retorna entries na ordem topológica
    return [nodes_map[k] for k in ordered_nodes if k in nodes_map]


def _reorder_files_by_dependencies(files: list[dict[str, Any]]) -> list[dict[str, Any]]:
    """
    Reordena 'files' da seguinte forma:
      1) Datasets (root) primeiro, na ordem atual (estável)
      2) Tabelas (subdir) com ordenação topológica baseada em 'depends_on'
      3) Demais arquivos subdir que não criam tabela (ex.: apenas data
         transfer), mantém ordem estável
    """
    roots = [e for e in files if e.get("path_type") == "root"]
    subdirs = [e for e in files if e.get("path_type") == "subdir"]

    # Tabelas que serão criadas
    table_entries = [
        e for e in subdirs if (e.get("content") or {}).get("table_create", True)
    ]
    # Subdirs que não são tabelas (ou table_create=False)
    non_table_subdirs = [
        e for e in subdirs if not (e.get("content") or {}).get("table_create", True)
    ]

    graph, nodes_map, unknown_deps = _build_table_graph(table_entries)

    if unknown_deps:
        # Apenas log informativo — pode representar tabelas externas (preexistentes)
        pulumi.log.info(
            "Algumas dependências referem-se a tabelas fora deste lote "
            "(serão tratadas como externas): " + ", ".join(sorted(unknown_deps))
        )

    ordered_tables = _toposort_tables(graph, nodes_map)

    # Mantém determinismo: para nós com mesmo nível de liberdade, _toposort_tables já
    # usa sorted() nos empates de queue/adjacências.
    return roots + ordered_tables + non_table_subdirs


def _infer_dataset_id_from_entry(entry: dict[str, Any]) -> str | None:
    """
    Tenta inferir dataset_id:
      1) do conteúdo (se existir),
      2) do nome do arquivo (bigquery/<dataset>.json),
      3) do nome da pasta (bigquery/<dataset>/<file>.json).
    """
    dataset_id = None

    # 1) Conteúdo
    content = entry.get("content", {}) or {}
    path_type = entry.get("path_type", "")
    if content.get("dataset_id"):
        return cast(str | None, content["dataset_id"])

    # 2) Path
    if not dataset_id:
        # entry["source"] exemplo: dataset/table/file...
        # Assumindo separador /
        source = entry["source"].replace("\\", "/").replace("__env__", ENVIRONMENT)
        parts = source.split("/")
        dataset_id = parts[1]

        # arquivo root: dataset/<table>.json
        if path_type == "root":
            dataset_id = dataset_id.replace(".json", "")
    return cast(str | None, dataset_id)


def _resolve_dependencies(
    entry: dict[str, Any], tables_by_name: dict[str, Any], opts: pulumi.ResourceOptions
) -> pulumi.ResourceOptions:
    """
    Resolve dependecies in the format dataset/table ou filename without .json
    """
    content = entry.get("content", {}) or {}
    extra_deps: list[pulumi.Resource] = []

    if content.get("depends_on"):
        for dep in content["depends_on"]:
            if dep in tables_by_name:
                extra_deps.append(tables_by_name[dep])
            else:
                pulumi.log.warn(
                    f"Dependency '{dep}' for '{entry['file_name']}' "
                    "not found in created tables (ORDER MATTERS!)."
                )

    if extra_deps:
        return pulumi.ResourceOptions.merge(
            opts, pulumi.ResourceOptions(depends_on=extra_deps)
        )
    return opts


def create_bigquery(
    template_vars: dict[str, str],
    opts: pulumi.ResourceOptions | None = None,
    json_files: list[dict[str, Any]] | None = None,
) -> dict[str, Any]:
    """
    Create BigQuery datasets and tables based on JSON configuration files.
    Wanted:
      - Datasets files at root: infra/gcp/auto/bigquery/<dataset>.json
      - Tables files inside dataset folder:
      infra/gcp/auto/bigquery/<dataset>/<any>.json

    Args:
        template_vars: Template variables for substitution
        opts: Pulumi resource options (opcional)
        json_files: (opcional) Loaded JSON files list for local tests.
            If None, use read_json_files(...) from SRC_INFRA_PATH.

    Returns:
        Dictionary containing created datasets and tables
    """
    # 1) Read JSONs (with variable substitution)
    if json_files is None:
        files = read_json_files(
            source_path=f"{SRC_INFRA_PATH}/gcp/auto/bigquery/",
            files_regex="**",
            template_vars=template_vars,
        )
    else:
        files = json_files

    # ordenação topológica baseada nas dependências
    files = _reorder_files_by_dependencies(files)

    # 2) Validate files and create resources
    datasets: list[Any] = []
    tables: list[Any] = []
    tables_by_name: dict[str, Any] = {}
    data_transfers: list[Any] = []
    routines: list[Any] = []
    for entry in files:
        content = entry.get("content", {}) or {}

        dataset_id = _infer_dataset_id_from_entry(entry)
        if not dataset_id:
            pulumi.log.warn(
                f"Not possible to infer dataset_id to {entry['source']}. "
                "Ignoring dataset and table creation."
            )
            continue

        bq_opts = pulumi.ResourceOptions()
        if opts:
            bq_opts = pulumi.ResourceOptions.merge(opts, bq_opts)

        # -------- Datasets --------
        if entry["path_type"] == "root":
            # 2.1) Validate files
            validate_entries(entries=[entry], schema=gcp_bigquery_dataset)

            # 2.2) Create resources
            dataset = gcp.bigquery.Dataset(
                resource_name=f"bq_dataset_{slugify(entry['file_name'])}",
                # list[gcp.bigquery.DatasetAccessArgs()]
                accesses=content.get("accesses"),
                dataset_id=dataset_id,
                default_collation=content.get("default_collation"),
                # gcp.bigquery.DatasetDefaultEncryptionConfigurationArgs()
                default_encryption_configuration=content.get(
                    "default_encryption_configuration"
                ),
                default_partition_expiration_ms=content.get(
                    "default_partition_expiration_ms"
                ),
                default_table_expiration_ms=content.get("default_table_expiration_ms"),
                delete_contents_on_destroy=content.get("delete_contents_on_destroy"),
                description=content.get("description"),
                # gcp.bigquery.DatasetExternalDatasetReferenceArgs()
                external_dataset_reference=content.get("external_dataset_reference"),
                friendly_name=content.get("friendly_name"),
                is_case_insensitive=content.get("is_case_insensitive"),
                project=GCP_PROJECT,
                labels=content.get("labels"),
                location=content.get("location", GCP_REGION),
                max_time_travel_hours=content.get("max_time_travel_hours"),
                storage_billing_model=content.get("storage_billing_model"),
                resource_tags=content.get("resource_tags"),
                opts=bq_opts,
            )
            datasets.append(dataset)

        dataset_opts = pulumi.ResourceOptions(depends_on=datasets)
        bq_opts = pulumi.ResourceOptions.merge(bq_opts, dataset_opts)

        if entry["path_type"] == "subdir":
            # -------- Routines --------
            # Routines are in path: bigquery/<dataset>/routines/<routine>.json
            is_routine = "/routines/" in entry.get("source", "")

            if is_routine:
                # Validate routine config
                validate_entries(entries=[entry], schema=gcp_bigquery_routine)

                # Resolve definition_body: content.definition_body or content.query
                # or read from companion .sql file
                definition_body = content.get("definition_body", "")
                if not definition_body:
                    definition_body = content.get("query", "")
                if not definition_body:
                    parts = entry["source"].split("/")
                    parent_path = "/".join(parts[:-1])
                    sql_file = read_non_json_files(
                        source_path=f"{SRC_INFRA_PATH}/gcp/auto/{parent_path}",
                        files_regex=f"{entry['file_name']}.sql",
                        template_vars=template_vars,
                    )
                    if sql_file:
                        definition_body = sql_file[0]["content_raw"]
                    else:
                        pulumi.log.warn(
                            f"SQL file not found for routine in {entry['source']}. "
                            "Definition body will be empty."
                        )

                # Build arguments
                routine_args: list[Any] = []
                arguments_config = content.get("arguments_config") or []
                for arg in arguments_config:
                    arg_data_type = arg.get("data_type")
                    if arg_data_type is not None and not isinstance(arg_data_type, str):
                        arg_data_type = json.dumps(arg_data_type)
                    routine_args.append(
                        gcp.bigquery.RoutineArgumentArgs(
                            name=arg.get("name"),
                            data_type=arg_data_type,
                            argument_kind=arg.get("argument_kind"),
                            mode=arg.get("mode"),
                        )
                    )

                routine_id = content.get("routine_id") or entry["file_name"]

                # return_type e return_table_type precisam ser string JSON
                return_type = content.get("return_type")
                if return_type is not None and not isinstance(return_type, str):
                    return_type = json.dumps(return_type)

                return_table_type = content.get("return_table_type")
                if return_table_type is not None and not isinstance(
                    return_table_type, str
                ):
                    return_table_type = json.dumps(return_table_type)

                # Alias para migração: aceita tanto o nome antigo (só file_name)
                # quanto o intermediário (dataset.file_name).
                routine_opts = pulumi.ResourceOptions.merge(
                    bq_opts,
                    pulumi.ResourceOptions(
                        aliases=[
                            pulumi.Alias(name=f"bq_routine_{slugify(f'{dataset_id}.{entry["file_name"]}')}")
                        ]
                    ),
                )
                routine = gcp.bigquery.Routine(
                    resource_name=f"bq_routine_{slugify(f'{dataset_id}.{entry["file_name"]}')}",
                    dataset_id=dataset_id,
                    routine_id=routine_id,
                    definition_body=definition_body,
                    routine_type=content.get("routine_type"),
                    language=content.get("language"),
                    arguments=routine_args if routine_args else None,
                    project=GCP_PROJECT,
                    return_type=return_type,
                    return_table_type=return_table_type,
                    imported_libraries=content.get("imported_libraries"),
                    description=content.get("description"),
                    determinism_level=content.get("determinism_level"),
                    opts=routine_opts,
                )
                routines.append(routine)
                continue

            # -------- Tables --------
            if content.get("table_create", True):
                # 2.1) Validate files
                validate_entries(entries=[entry], schema=gcp_bigquery_table)

                # 2.2) Create resources
                view = content.get("view") or {}
                view_query = view.get("query", "")
                # Objects (SQL): arquivos sql na mesma pasta do JSON
                if view != {} and view_query == "":
                    parts = entry["source"].split("/")
                    parent_path = "/".join(parts[:-1])
                    sql_file = read_non_json_files(
                        source_path=f"{SRC_INFRA_PATH}/gcp/auto/{parent_path}",
                        files_regex=f"{entry['file_name']}.sql",
                        template_vars=template_vars,
                    )
                    if sql_file:
                        view["query"] = sql_file[0]["content_raw"]
                    else:
                        pulumi.log.warn(
                            f"SQL file not found for view in {entry['source']}. "
                            "View query will be empty."
                        )

                # Alias para migração: aceita tanto o nome antigo (só file_name)
                # quanto o intermediário (dataset.file_name).
                table_opts = pulumi.ResourceOptions.merge(
                    bq_opts,
                    pulumi.ResourceOptions(
                        aliases=[
                            pulumi.Alias(name=f"bq_table_{slugify(f'{dataset_id}.{entry["file_name"]}')}")
                        ]
                    ),
                )
                table = gcp.bigquery.Table(
                    resource_name=f"bq_table_{slugify(f'{dataset_id}.{entry["file_name"]}')}",
                    clusterings=content.get("clustering"),
                    dataset_id=dataset_id,
                    deletion_protection=content.get("deletion_protection"),
                    description=content.get("description"),
                    # gcp.bigquery.TableEncryptionConfigurationArgs()
                    encryption_configuration=content.get("encryption_configuration"),
                    expiration_time=content.get("expiration_time"),
                    # gcp.bigquery.TableExternalDataConfigurationArgs()
                    external_data_configuration=content.get(
                        "external_data_configuration"
                    ),
                    friendly_name=content.get("friendly_name"),
                    labels=content.get("labels"),
                    # gcp.bigquery.TableMaterializedViewArgs()
                    materialized_view=content.get("materialized_view"),
                    max_staleness=content.get("max_staleness"),
                    project=GCP_PROJECT,
                    # gcp.bigquery.TableRangePartitioningArgs()
                    range_partitioning=content.get("range_partitioning"),
                    require_partition_filter=content.get("require_partition_filter"),
                    resource_tags=content.get("resource_tags"),
                    schema=json.dumps(content.get("schema")),
                    table_id=entry.get("file_name"),
                    # gcp.bigquery.TableTableConstraintsArgs()
                    table_constraints=content.get("table_constraints"),
                    # gcp.bigquery.TableTableReplicationInfoArgs()
                    table_replication_info=content.get("table_replication_info"),
                    # gcp.bigquery.TableTimePartitioningArgs()
                    time_partitioning=content.get("time_partitioning"),
                    # gcp.bigquery.TableViewArgs()
                    view=cast(Any, view) if view else None,
                    opts=_resolve_dependencies(entry, tables_by_name, table_opts),
                )
                tables.append(table)
                # Store for dependency lookup
                tables_by_name[entry["file_name"]] = table
                tables_by_name[f"{dataset_id}/{entry['file_name']}"] = table

            # -------- Data Transfer --------
            if content.get("data_transfer_create", False):
                # 2.1) Validate files
                validate_entries(entries=[entry], schema=gcp_bigquery_data_transfer)

                params = content.get("params") or {}
                # Se for scheduled_query e não tiver query definida, busca do arquivo .sql
                if content.get("data_source_id") == "scheduled_query" and not params.get("query"):
                    parts = entry["source"].split("/")
                    parent_path = "/".join(parts[:-1])
                    sql_file = read_non_json_files(
                        source_path=f"{SRC_INFRA_PATH}/gcp/auto/{parent_path}",
                        files_regex=f"{entry['file_name']}.sql",
                        template_vars=template_vars,
                    )
                    if sql_file:
                        params["query"] = sql_file[0]["content_raw"]
                        content["params"] = params
                    else:
                        pulumi.log.warn(
                            f"SQL file not found for scheduled_query in {entry['source']}. "
                            "Query parameter will be empty."
                        )

                # 2.2) Create resources
                data_transfer = gcp.bigquery.DataTransferConfig(
                    resource_name=f"bq_transfer_{slugify(entry['file_name'])}",
                    data_refresh_window_days=content.get("data_refresh_window_days"),
                    data_source_id=content.get("data_source_id"),
                    destination_dataset_id=content.get("destination_dataset_id"),
                    display_name=content.get("display_name"),
                    disabled=content.get("disabled"),
                    # gcp.bigquery.DataTransferConfigEmailPreferencesArgs()
                    email_preferences=content.get("email_preferences"),
                    # gcp.bigquery.DataTransferConfigEncryptionConfigurationArgs()
                    encryption_configuration=content.get("encryption_configuration"),
                    location=content.get("location", GCP_REGION),
                    notification_pubsub_topic=content.get("notification_pubsub_topic"),
                    params=content.get("params"),
                    project=GCP_PROJECT,
                    schedule=content.get("schedule"),
                    # gcp.bigquery.DataTransferConfigScheduleOptionsArgs()
                    schedule_options=content.get("schedule_options"),
                    # gcp.bigquery.DataTransferConfigSensitiveParamsArgs()
                    sensitive_params=content.get("sensitive_params"),
                    service_account_name=content.get("service_account_name"),
                    opts=bq_opts,
                )
                data_transfers.append(data_transfer)

    return {
        "datasets": datasets,
        "tables": tables,
        "data_transfers": data_transfers,
        "routines": routines,
    }
