# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

"""
GCP VPC Network component.
References:
https://www.pulumi.com/registry/packages/gcp/api-docs/compute/
https://www.pulumi.com/registry/packages/gcp/api-docs/compute/address/
https://www.pulumi.com/registry/packages/gcp/api-docs/compute/globaladdress/
https://www.pulumi.com/registry/packages/gcp/api-docs/compute/network/
https://www.pulumi.com/registry/packages/gcp/api-docs/compute/subnetwork/
https://www.pulumi.com/registry/packages/gcp/api-docs/compute/firewall/
"""

from __future__ import annotations

from typing import Any

import pulumi_gcp as gcp
from utils.json_reader import read_json_files, slugify
from utils.schemas import gcp_vpc_network
from utils.validations import validate_entries
from variables import GCP_PROJECT, GCP_REGION, SRC_INFRA_PATH

import pulumi


def _create_address(
    entry: dict[str, Any], opts: pulumi.ResourceOptions | None = None
) -> Any:
    """
    Create Address based on entry.

    Args:
        entry: Entry
        opts: Pulumi resource options (opcional)
    Returns:
        Dictionary of created Address resource
    """
    content = entry.get("content", {}) or {}
    ip_scope = content.get("ip_type", "global")
    address_type = content.get("address_type", "EXTERNAL")

    address_args = {
        "address": content.get("address"),
        "address_type": address_type,
        "description": content.get("ip_description"),
        "ip_version": content.get("ip_version"),
        "labels": content.get("ip_labels"),
        "name": content.get("ip_name"),
        "project": GCP_PROJECT,
    }

    if address_type == "INTERNAL":
        address_args["network"] = (
            content.get("network") if not content.get("subnetwork") else None
        )
        address_args["prefix_length"] = content.get("prefix_length")
        address_args["purpose"] = content.get("address_purpose")

    address: Any = None
    if ip_scope == "regional":
        address_args["ip_collection"] = content.get("ip_collection")
        address_args["ipv6_endpoint_type"] = content.get("ipv6_endpoint_type")
        address_args["network_tier"] = content.get("network_tier")
        address_args["region"] = content.get("location", GCP_REGION)
        address_args["subnetwork"] = content.get("subnetwork")

        address = gcp.compute.Address(
            resource_name=f"address_{slugify(entry['file_name'])}",
            **{k: v for k, v in address_args.items() if v is not None},
            opts=opts,
        )
    else:
        address = gcp.compute.GlobalAddress(
            resource_name=f"address_{slugify(entry['file_name'])}",
            **{k: v for k, v in address_args.items() if v is not None},
            opts=opts,
        )

    return address


def _create_network(
    entry: dict[str, Any], opts: pulumi.ResourceOptions | None = None
) -> Any:
    """
    Create Network based on entry.

    Args:
        entry: Entry
        opts: Pulumi resource options (opcional)
    Returns:
        Dictionary of created Network resource
    """
    content = entry.get("content", {}) or {}

    network = gcp.compute.Network(
        resource_name=f"network_{slugify(entry['file_name'])}",
        auto_create_subnetworks=content.get("auto_create_subnetworks", False),
        bgp_always_compare_med=content.get("bgp_always_compare_med"),
        bgp_best_path_selection_mode=content.get("bgp_best_path_selection_mode"),
        bgp_inter_region_cost=content.get("bgp_inter_region_cost"),
        delete_bgp_always_compare_med=content.get("delete_bgp_always_compare_med"),
        delete_default_routes_on_create=content.get("delete_default_routes_on_create"),
        description=content.get("network_description"),
        enable_ula_internal_ipv6=content.get("enable_ula_internal_ipv6"),
        internal_ipv6_range=content.get("internal_ipv6_range"),
        mtu=content.get("mtu"),
        name=content.get("network"),
        network_firewall_policy_enforcement_order=content.get(
            "network_firewall_policy_enforcement_order"
        ),
        network_profile=content.get("network_profile"),
        # gcp.compute.NetworkParamsArgs()
        params=content.get("network_params"),
        project=GCP_PROJECT,
        routing_mode=content.get("routing_mode"),
        opts=opts,
    )

    return network


def _create_subnetwork(
    entry: dict[str, Any], opts: pulumi.ResourceOptions | None = None
) -> Any:
    """
    Create Subnetwork based on entry.

    Args:
        entry: Entry
        opts: Pulumi resource options (opcional)
    Returns:
        Dictionary of created Subnetwork resource
    """
    content = entry.get("content", {}) or {}

    subnetwork = gcp.compute.Subnetwork(
        resource_name=f"subnetwork_{slugify(entry['file_name'])}",
        allow_subnet_cidr_routes_overlap=content.get(
            "allow_subnet_cidr_routes_overlap"
        ),
        description=content.get("subnetwork_description"),
        external_ipv6_prefix=content.get("external_ipv6_prefix"),
        internal_ipv6_prefix=content.get("internal_ipv6_prefix"),
        ip_cidr_range=content.get("ip_cidr_range"),
        ip_collection=content.get("ip_collection"),
        ipv6_access_type=content.get("ipv6_access_type"),
        # gcp.compute.SubnetworkLogConfigArgs()
        log_config=content.get("subnetwork_log_config"),
        name=content.get("subnetwork"),
        network=content.get("network"),
        # gcp.compute.SubnetworkParamsArgs()
        params=content.get("subnetwork_params"),
        private_ip_google_access=content.get("private_ip_google_access"),
        private_ipv6_google_access=content.get("private_ipv6_google_access"),
        project=GCP_PROJECT,
        purpose=content.get("subnetwork_purpose"),
        region=content.get("location", GCP_REGION),
        reserved_internal_range=content.get("reserved_internal_range"),
        resolve_subnet_mask=content.get("resolve_subnet_mask"),
        role=content.get("role"),
        # list(gcp.compute.SubnetworkSecondaryIpRangeArgs())
        secondary_ip_ranges=content.get("secondary_ip_ranges"),
        send_secondary_ip_range_if_empty=content.get(
            "send_secondary_ip_range_if_empty"
        ),
        stack_type=content.get("stack_type"),
        opts=opts,
    )

    return subnetwork


def _create_firewall(
    entry: dict[str, Any], opts: pulumi.ResourceOptions | None = None
) -> Any:
    """
    Create Firewall Rules based on entry.

    Args:
        entry: Entry
        opts: Pulumi resource options (opcional)
    Returns:
        Dictionary of created Firewall Rules resource
    """
    content = entry.get("content", {}) or {}

    firewall = gcp.compute.Firewall(
        resource_name=f"firewall_rules_{slugify(entry['file_name'])}",
        # list(gcp.compute.FirewallAllowArgs())
        allows=content.get("allow"),
        # list(gcp.compute.FirewallDenyArgs())
        denies=content.get("deny"),
        description=content.get("firewall_description"),
        destination_ranges=content.get("destination_ranges"),
        direction=content.get("direction"),
        disabled=content.get("disabled"),
        enable_logging=content.get("enable_logging"),
        # gcp.compute.FirewallLogConfigArgs()
        log_config=content.get("firewall_log_config"),
        name=content.get("firewall_name"),
        network=content.get("network"),
        # gcp.compute.FirewallParamsArgs()
        params=content.get("firewall_params"),
        priority=content.get("priority"),
        project=GCP_PROJECT,
        source_ranges=content.get("source_ranges"),
        source_service_accounts=content.get("source_service_accounts"),
        source_tags=content.get("source_tags"),
        target_service_accounts=content.get("target_service_accounts"),
        target_tags=content.get("target_tags"),
        opts=opts,
    )

    return firewall


def create_vpc_network(
    template_vars: dict[str, str],
    opts: pulumi.ResourceOptions | None = None,
    json_files: list[dict[str, Any]] | None = None,
) -> dict[str, Any]:
    """
    Create Vpc Network based on JSON configuration files.
    Files should be at root: infra/gcp/auto/vpc_network/<any>.json

    Args:
        template_vars: Template variables for substitution
        opts: Pulumi resource options (opcional)
        json_files: (opcional) Loaded JSON files list for local tests.
            If None, use read_json_files(...) from SRC_INFRA_PATH.

    Returns:
        Dictionary of created Vpc Network resources
    """
    # 1) Read JSONs (with variable substitution)
    if json_files is None:
        files = read_json_files(
            source_path=f"{SRC_INFRA_PATH}/gcp/auto/vpc_network/",
            files_regex="**",
            template_vars=template_vars,
        )
    else:
        files = json_files

    # 2) Validate files and create resources
    addresses: list[Any] = []
    networks: list[Any] = []
    subnetworks: list[Any] = []
    firewall_rules: list[Any] = []

    for entry in files:
        content = entry.get("content", {}) or {}

        # 2.1) Validate files
        validate_entries(entries=[entry], schema=gcp_vpc_network)

        # 2.2) Create resources in dependency order
        # -------- Network --------
        if content.get("network_create"):
            network = _create_network(entry, opts)
            networks.append(network)

        # -------- Subnetwork --------
        if content.get("subnetwork_create"):
            subnetwork = _create_subnetwork(entry, opts)
            subnetworks.append(subnetwork)

        # -------- Address --------
        if content.get("ip_name"):
            address = _create_address(entry, opts)
            addresses.append(address)

        # -------- Firewall Rules --------
        if content.get("firewall_name"):
            firewall = _create_firewall(entry, opts)
            firewall_rules.append(firewall)

    return {
        "addresses": addresses,
        "networks": networks,
        "subnetworks": subnetworks,
        "firewall_rules": firewall_rules,
    }
