# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

"""
GCP Eventarc component.
References:
https://www.pulumi.com/registry/packages/gcp/api-docs/eventarc/
"""

from __future__ import annotations

from typing import Any

import pulumi_gcp as gcp
from utils.json_reader import read_json_files, slugify
from utils.schemas import gcp_eventarc_trigger
from utils.validations import validate_entries
from variables import GCP_PROJECT, GCP_REGION, SRC_INFRA_PATH

import pulumi


def create_eventarc_triggers(
    template_vars: dict[str, str],
    opts: pulumi.ResourceOptions | None = None,
    json_files: list[dict[str, Any]] | None = None,
) -> dict[str, Any]:
    """
    Create Eventarc triggers.
    Files should be at root: infra/gcp/auto/cloud_functions/<any>.json

    Args:
        template_vars: Template variables for substitution
        opts: Pulumi resource options (opcional)
        json_files: (opcional) Loaded JSON files list for local tests.
            If None, use read_json_files(...) from SRC_INFRA_PATH.

    Returns:
        Dictionary of created Cloud Functions
    """
    # 1) Read JSONs (with variable substitution)
    if json_files is None:
        files = read_json_files(
            source_path=f"{SRC_INFRA_PATH}/gcp/auto/eventarc/",
            files_regex="**",
            template_vars=template_vars,
        )
    else:
        files = json_files

    # 2) Validate files and create resources
    triggers: list[Any] = []
    for entry in files:
        content = entry.get("content", {}) or {}

        # 2.1) Validate files
        validate_entries(entries=[entry], schema=gcp_eventarc_trigger)

        # 2.2) Create resources
        trigger_args = {
            "name": entry.get("file_name"),
            "project": GCP_PROJECT,
            "location": content.get("location", GCP_REGION),
            "channel": content.get("channel"),
            "event_data_content_type": content.get("event_data_content_type"),
            "labels": content.get("labels"),
            "service_account": content.get("service_account"),
            "matching_criterias": [
                gcp.eventarc.TriggerMatchingCriteriaArgs(**mc)
                for mc in content.get("matching_criteria", [])
            ],
        }

        if content.get("destination"):
            trigger_args["destination"] = gcp.eventarc.TriggerDestinationArgs(
                **content["destination"]
            )

        if content.get("transport"):
            trigger_args["transport"] = gcp.eventarc.TriggerTransportArgs(
                **content["transport"]
            )

        trigger = gcp.eventarc.Trigger(
            f"eventarc_trigger_{slugify(entry['source'])}",
            **{k: v for k, v in trigger_args.items() if v is not None},
            opts=opts,
        )
        triggers.append(trigger)

    return {"triggers": triggers}
