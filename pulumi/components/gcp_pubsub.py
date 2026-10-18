# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

"""
GCP Pub/Sub component.
References:
https://www.pulumi.com/registry/packages/gcp/api-docs/pubsub/
https://www.pulumi.com/registry/packages/gcp/api-docs/pubsub/topic/
"""

from __future__ import annotations

from typing import Any, cast

import pulumi_gcp as gcp
from utils.json_reader import read_json_files, slugify
from utils.schemas import gcp_pubsub_subscription, gcp_pubsub_topic
from utils.validations import validate_entries
from variables import ENVIRONMENT, GCP_PROJECT, SRC_INFRA_PATH

import json
import pulumi


def _infer_topic_id_from_entry(entry: dict[str, Any]) -> str | None:
    """
    Try to infer topic_id:
      1) from content (if exists),
      2) from filename (pubsub/<topic>.json),
      3) from foldername (pubsub/<topic>/<file>.json).
    """
    topic_id = None

    # 1) Conteúdo
    content = entry.get("content", {}) or {}
    path_type = entry.get("path_type", "")
    if content.get("topic_id"):
        return cast(str | None, content["topic_id"])

    # 2) Path
    if not topic_id:
        # entry["source"] exemplo: pubsub/topic/file...
        # Assumindo separador /
        source = entry["source"].replace("\\", "/").replace("__env__", ENVIRONMENT)
        parts = source.split("/")
        repository_id = parts[1]

        # arquivo root: pubsub/<topic>.json
        if path_type == "root":
            repository_id = repository_id.replace(".json", "")
    return cast(str | None, repository_id)


def create_pubsub(
    template_vars: dict[str, str],
    opts: pulumi.ResourceOptions | None = None,
    json_files: list[dict[str, Any]] | None = None,
) -> dict[str, Any]:
    """
    Create GCP Pub/Sub resources based on JSON configuration files.
    Wanted:
      - Topics files at root: infra/gcp/auto/pubsub/<topic>.json
      - Subscriptions files inside topic folder:
      infra/gcp/auto/pubsub/<topic>/<any>.json

    Args:
        template_vars: Template variables for substitution
        opts: Pulumi resource options (opcional)
        json_files: (opcional) Loaded JSON files list for local tests.
            If None, use read_json_files(...) from SRC_INFRA_PATH.

    Returns:
        List of created GCP Pub/Sub resources
    """
    # 1) Read JSONs (with variable substitution)
    if json_files is None:
        files = read_json_files(
            source_path=f"{SRC_INFRA_PATH}/gcp/auto/pubsub/",
            files_regex="**",
            template_vars=template_vars,
        )
    else:
        files = json_files

    # 2) Validate files and create resources
    schemas: list[Any] = []
    topics: list[Any] = []
    subscriptions: list[Any] = []
    created_topics_map: dict[str, Any] = {}
    for entry in files:
        content = entry.get("content", {}) or {}
        topic_id = _infer_topic_id_from_entry(entry)
        if not topic_id:
            pulumi.log.warn(
                f"Not possible to infer topic_id to {entry['source']}. "
                "Ignoring topic and subscription creation."
            )
            continue

        # -------- Topic --------
        if entry["path_type"] == "root":
            # 2.1) Validate files
            validate_entries(entries=[entry], schema=gcp_pubsub_topic)

            # 2.2) Create resources
            if content.get("definition") is not None:
                schema = gcp.pubsub.Schema(
                    resource_name=f"pssc_{slugify(entry['file_name'])}",
                    definition=json.dumps(content.get("definition")),
                    deletion_policy=content.get("deletion_policy"),
                    name=entry['file_name'],
                    project=GCP_PROJECT,
                    type=content.get("type"),
                    opts=opts,
                )
                schemas.append(schema)

            if (
                content.get("labels") is not None or
                content.get("message_retention_duration") is not None or
                content.get("message_storage_policy") is not None or
                content.get("message_transforms") is not None or
                content.get("schema_settings") is not None or
                content.get("tags") is not None
            ):
                topic = gcp.pubsub.Topic(
                    resource_name=f"pb_topic_{slugify(entry['file_name'])}",
                    # gcp.pubsub.TopicIngestionDataSourceSettingsArgs()
                    ingestion_data_source_settings=content.get(
                        "ingestion_data_source_settings"
                    ),
                    kms_key_name=content.get("kms_key_name"),
                    labels=content.get("labels"),  # dict(str,str)
                    message_retention_duration=content.get("message_retention_duration"),
                    # gcp.pubsub.TopicMessageStoragePolicyArgs()
                    message_storage_policy=content.get("message_storage_policy"),
                    # list(gcp.pubsub.TopicMessageTransformArgs())
                    message_transforms=content.get("message_transforms"),
                    name=topic_id,
                    project=GCP_PROJECT,
                    # gcp.pubsub.TopicSchemaSettingsArgs()
                    schema_settings=content.get("schema_settings"),
                    tags=content.get("tags"),
                    opts=opts,
                )
                topics.append(topic)
                created_topics_map[topic_id] = topic

        # -------- Subscription --------
        if entry["path_type"] == "subdir":
            # 3.1) Validate files
            validate_entries(entries=[entry], schema=gcp_pubsub_subscription)

            # 3.2) Create resources
            parent_topic = created_topics_map.get(topic_id)
            subscription = gcp.pubsub.Subscription(
                resource_name=f"pb_subscrip_{slugify(entry['file_name'])}",
                ack_deadline_seconds=content.get("ack_deadline_seconds"),
                # gcp.pubsub.SubscriptionBigqueryConfigArgs()
                bigquery_config=content.get("bigquery_config"),
                # gcp.pubsub.SubscriptionCloudStorageConfigArgs()
                cloud_storage_config=content.get("cloud_storage_config"),
                # gcp.pubsub.SubscriptionDeadLetterPolicyArgs()
                dead_letter_policy=content.get("dead_letter_policy"),
                enable_exactly_once_delivery=content.get(
                    "enable_exactly_once_delivery"
                ),
                enable_message_ordering=content.get("enable_message_ordering"),
                # gcp.pubsub.SubscriptionExpirationPolicyArgs()
                expiration_policy=content.get("expiration_policy"),
                filter=content.get("filter"),
                labels=content.get("labels"),
                name=entry.get("file_name"),
                message_retention_duration=content.get("message_retention_duration"),
                # list(gcp.pubsub.SubscriptionMessageTransformArgs)
                message_transforms=content.get("message_transforms"),
                project=GCP_PROJECT,
                # gcp.pubsub.SubscriptionPushConfigArgs
                push_config=content.get("push_config"),
                retain_acked_messages=content.get("retain_acked_messages"),
                # gcp.pubsub.SubscriptionRetryPolicyArgs
                retry_policy=content.get("retry_policy"),
                tags=content.get("tags"),
                topic=topic_id,
                opts=pulumi.ResourceOptions(
                    parent=parent_topic if parent_topic else None,
                    depends_on=[parent_topic] if parent_topic else [],
                ),
            )
            subscriptions.append(subscription)

    return {
        "schemas": schemas,
        "topics": topics,
        "subscriptions": subscriptions,
    }
