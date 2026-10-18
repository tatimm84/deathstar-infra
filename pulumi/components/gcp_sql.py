# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

"""
GCP SQL component.
References:
https://www.pulumi.com/registry/packages/gcp/api-docs/sql/
"""

from __future__ import annotations

from typing import Any

import pulumi_gcp as gcp
from utils.json_reader import read_json_files, slugify
from utils.schemas import gcp_sql
from utils.validations import validate_entries
from variables import GCP_PROJECT, GCP_REGION, SRC_INFRA_PATH

import pulumi


def create_sql(
    template_vars: dict[str, str],
    opts: pulumi.ResourceOptions | None = None,
    json_files: list[dict[str, Any]] | None = None,
) -> dict[str, Any]:
    """
    Create SQL resources based on JSON configuration files.
    Files should be at root: infra/gcp/auto/sql/<any>.json

    Args:
        template_vars: Template variables for substitution
        opts: Pulumi resource options (opcional)
        json_files: (opcional) Loaded JSON files list for local tests.
            If None, use read_json_files(...) from SRC_INFRA_PATH.

    Returns:
        List of created SQL resources
    """
    # 1) Read JSONs (with variable substitution)
    if json_files is None:
        files = read_json_files(
            source_path=f"{SRC_INFRA_PATH}/gcp/auto/sql/",
            files_regex="**",
            template_vars=template_vars,
        )
    else:
        files = json_files

    # 2) Validate files, extract subdict with security and create resources
    instances: list[Any] = []
    databases: list[Any] = []
    users: list[Any] = []
    ssl_certs: list[Any] = []
    for entry in files:
        content = entry.get("content", {}) or {}

        # 2.1) Validate files
        validate_entries(entries=[entry], schema=gcp_sql)

        # 2.2) Extract subdict with security and create resources
        # -------- Instances --------
        if content.get("sql_instance_create"):
            instance = gcp.sql.DatabaseInstance(
                resource_name=f"sql_instance_{slugify(entry['file_name'])}",
                backupdr_backup=content.get("backupdr_backup"),  # str
                # gcp.sql.DatabaseInstanceCloneArgs()
                clone=content.get("clone"),
                database_version=content.get("database_version"),  # str
                deletion_protection=content.get("deletion_protection"),  # bool
                encryption_key_name=content.get("encryption_key_name"),  # str
                final_backup_description=content.get("final_backup_description"),  # str
                instance_type=content.get("instance_type"),  # str
                maintenance_version=content.get("maintenance_version"),  # str
                master_instance_name=content.get("master_instance_name"),  # str
                name=content.get("sql_instance_name"),  # str
                node_count=content.get("node_count"),  # int
                # gcp.sql.DatabaseInstancePointInTimeRestoreContextArgs()
                point_in_time_restore_context=content.get(
                    "point_in_time_restore_context"
                ),
                project=GCP_PROJECT,
                region=content.get("location", GCP_REGION),
                # gcp.sql.DatabaseInstanceReplicaConfigurationArgs()
                replica_configuration=content.get("replica_configuration"),
                replica_names=content.get("replica_names"),  # list(str)
                # gcp.sql.DatabaseInstanceReplicationClusterArgs()
                replication_cluster=content.get("replication_cluster"),
                # gcp.sql.DatabaseInstanceRestoreBackupContextArgs()
                restore_backup_context=content.get("restore_backup_context"),
                root_password=content.get("root_password"),  # str
                root_password_wo=content.get("root_password_wo"),  # str
                root_password_wo_version=content.get("root_password_wo_version"),  # str
                # gcp.sql.DatabaseInstanceSettingsArgs
                settings=content.get("sql_instance_settings"),
                opts=opts,
            )
            instances.append(instance)

        # -------- Databases --------
        sql_databases = content.get("sql_databases") or []
        if sql_databases:
            for db in sql_databases:
                db_name = db.get("name")
                database = gcp.sql.Database(
                    resource_name=f"sql_database_{slugify(entry['file_name'])}_{db_name}",
                    charset=db.get("charset"),
                    collation=db.get("collation"),
                    deletion_policy=db.get("deletion_policy"),
                    instance=instance.name,
                    name=db_name,
                    project=GCP_PROJECT,
                    opts=pulumi.ResourceOptions(parent=instance),
                )
                databases.append(database)

        # -------- Users --------
        sql_users = content.get("sql_users") or []
        if sql_users:
            for usr in sql_users:
                usr_name = usr.get("name")
                user = gcp.sql.User(
                    resource_name=f"sql_database_{slugify(entry['file_name'])}_{usr_name}",
                    deletion_policy=usr.get("deletion_policy"),
                    host=usr.get("host"),
                    instance=instance.name,
                    name=usr_name,
                    project=GCP_PROJECT,
                    password=usr_name.get("password"),
                    # gcp.sql.UserPasswordPolicyArgs()
                    password_policy=usr.get("password_policy"),
                    password_wo=usr.get("password_wo"),
                    password_wo_version=usr.get("password_wo_version"),  # int
                    type=usr.get("type"),
                    opts=pulumi.ResourceOptions(parent=instance),
                )
                users.append(user)

        # -------- SSL certificates --------
        sql_ssl_certs = content.get("sql_ssl_certs") or []
        if sql_ssl_certs:
            for cert in sql_ssl_certs:
                cert_name = cert.get("common_name")
                ssl_cert = gcp.sql.SslCert(
                    f"sql_ssl_cert_{entry['source']}_{cert_name}",
                    common_name=cert_name,
                    instance=instance.name,
                    project=GCP_PROJECT,
                    opts=pulumi.ResourceOptions(parent=instance),
                )
                ssl_certs.append(ssl_cert)

    return {
        "instances": instances,
        "databases": databases,
        "users": users,
        "ssl_certs": ssl_certs,
    }
