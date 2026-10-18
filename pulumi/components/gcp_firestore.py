"""
GCP Firestore component.
References:
https://www.pulumi.com/registry/packages/gcp/api-docs/firestore/
https://www.pulumi.com/registry/packages/gcp/api-docs/firestore/database/
https://www.pulumi.com/registry/packages/gcp/api-docs/firestore/--index/

"""

from __future__ import annotations

from typing import Any, cast

import pulumi_gcp as gcp
from utils.json_reader import read_json_files, slugify
from utils.schemas import gcp_firestore_database, gcp_firestore_index
from utils.validations import validate_entries
from variables import ENVIRONMENT, GCP_PROJECT, GCP_REGION, SRC_INFRA_PATH

import pulumi


def _infer_database_id_from_entry(entry: dict[str, Any]) -> str | None:
    """
    Tenta inferir database_id:
      1) do conteúdo (se existir),
      2) do nome do arquivo (firestore/<database>.json),
      3) do nome da pasta (firestore/<database>/<file>.json).
    """
    database_id: str | None = None

    # 1) Conteúdo
    content = entry.get("content", {}) or {}
    path_type = entry.get("path_type", "")
    if content.get("database_id"):
        return cast(str | None, content["database_id"])

    # 2) Path
    if not database_id:
        # entry["source"] exemplo: dataset/table/file...
        # Assumindo separador /
        source = entry["source"].replace("\\", "/").replace("__env__", ENVIRONMENT)
        parts = source.split("/")
        database_id = parts[1]

        # arquivo root: dataset/<table>.json
        if path_type == "root":
            database_id = database_id.replace(".json", "")
    return cast(str | None, database_id)


def create_firestore(
    template_vars: dict[str, str],
    opts: pulumi.ResourceOptions | None = None,
    json_files: list[dict[str, Any]] | None = None,
) -> dict[str, Any]:
    """
    Create Firestore databases and indexes based on JSON configuration files.
    Files should be at root: infra/gcp/auto/firestore/<any>.json

    Args:
        template_vars: Template variables for substitution
        opts: Pulumi resource options (opcional)
        json_files: (opcional) Loaded JSON files list for local tests.
            If None, use read_json_files(...) from SRC_INFRA_PATH.

    Returns:
        Dictionary with created Firestore resources
    """
    # 1) Read JSONs (with variable substitution)
    if json_files is None:
        files = read_json_files(
            source_path=f"{SRC_INFRA_PATH}/gcp/auto/firestore/",
            files_regex="**",
            template_vars=template_vars,
        )
    else:
        files = json_files

    # 2) Validate files and create resources
    databases: list[Any] = []
    indexes: list[Any] = []
    for entry in files:
        content = entry.get("content", {}) or {}

        database_id = _infer_database_id_from_entry(entry)
        if not database_id:
            pulumi.log.warn(
                f"Not possible to infer database_id to {entry['source']}. "
                "Ignoring database and index creation."
            )
            continue

        fr_opts = pulumi.ResourceOptions()
        if opts:
            fr_opts = pulumi.ResourceOptions.merge(opts, fr_opts)

        # -------- Databases --------
        if entry["path_type"] == "root":
            # 2.1) Validate files
            validate_entries(entries=[entry], schema=gcp_firestore_database)

            # 2.2) Create resources
            database = gcp.firestore.Database(
                resource_name=f"firestore_db_{slugify(entry['file_name'])}",
                app_engine_integration_mode=content.get("app_engine_integration_mode"),
                cmek_config=content.get("cmek_config"),
                concurrency_mode=content.get("concurrency_mode"),
                database_edition=content.get("database_edition"),
                deletion_policy=content.get("deletion_policy"),
                delete_protection_state=content.get("delete_protection_state"),
                location_id=content.get("location", GCP_REGION),
                name=content.get("name", entry["file_name"]),
                point_in_time_recovery_enablement=content.get(
                    "point_in_time_recovery_enablement"
                ),
                project=GCP_PROJECT,
                tags=content.get("tags"),
                type=content.get("type"),
                opts=fr_opts,
            )
            databases.append(database)

        database_opts = pulumi.ResourceOptions(depends_on=databases)
        fr_opts = pulumi.ResourceOptions.merge(fr_opts, database_opts)

        if entry["path_type"] == "subdir":
            # -------- Tables --------
            if content.get("table_create", True):
                # 2.1) Validate files
                validate_entries(entries=[entry], schema=gcp_firestore_index)

                # 2.2) Create resources
                index = gcp.firestore.Index(
                    resource_name=f"firestore_index_{slugify(entry['file_name'])}",
                    api_scope=content.get("api_scope"),
                    collection=content.get("collection"),
                    database=content.get("database", database_id),
                    density=content.get("density"),
                    fields=content.get("fields"),
                    multikey=content.get("multikey"),
                    project=GCP_PROJECT,
                    query_scope=content.get("query_scope"),
                    unique=content.get("unique"),
                    opts=fr_opts,
                )
                indexes.append(index)

    return {"databases": databases, "indexes": indexes}
