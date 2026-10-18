# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

"""
GCP Cloud NAT component.
References:
https://www.pulumi.com/registry/packages/gcp/api-docs/compute/
https://www.pulumi.com/registry/packages/gcp/api-docs/compute/router/
https://www.pulumi.com/registry/packages/gcp/api-docs/compute/routernat/
"""

from __future__ import annotations

from typing import Any

import pulumi_gcp as gcp
from utils.json_reader import read_json_files, slugify
from utils.schemas import gcp_cloud_nat_gateway
from utils.validations import validate_entries
from variables import GCP_PROJECT, GCP_REGION, SRC_INFRA_PATH

import pulumi


def _create_router(
    entry: dict[str, Any],
    opts: pulumi.ResourceOptions | None = None,
) -> Any:
    """
    Create Cloud Router based on entry.

    Args:
        entry: Entry
        opts: Pulumi resource options (opcional)
    Returns:
        Dictionary of created Routers resource
    """
    content = entry.get("content", {}) or {}

    router = gcp.compute.Router(
        resource_name=f"router_{slugify(entry['file_name'])}",
        # gcp.compute.RouterBgpArgs()
        bgp=content.get("bgp"),
        description=content.get("description"),
        encrypted_interconnect_router=content.get("encrypted_interconnect_router"),
        # gcp.compute.RouterMd5AuthenticationKeysArgs()
        md5_authentication_keys=content.get("md5_authentication_keys"),
        name=content["router"],
        network=content.get("network"),
        ncc_gateway=content.get("ncc_gateway"),
        # gcp.compute.RouterParamsArgs()
        params=content.get("params"),
        project=GCP_PROJECT,
        region=content.get("location", GCP_REGION),
        opts=opts,
    )

    return router


def _create_nat(
    entry: dict[str, Any],
    opts: pulumi.ResourceOptions | None = None,
) -> Any:
    """
    Create Cloud NAT Gateway based on entry.

    Args:
        entry: Entry
        opts: Pulumi resource options (opcional)
    Returns:
        Dictionary of created NAT Gateways resource
    """
    content = entry.get("content", {}) or {}

    nat = gcp.compute.RouterNat(
        resource_name=f"nat_{slugify(entry['file_name'])}",
        auto_network_tier=content.get("auto_network_tier"),
        drain_nat_ips=content.get("drain_nat_ips"),
        endpoint_types=content.get("endpoint_types"),
        enable_dynamic_port_allocation=content.get("enable_dynamic_port_allocation"),
        enable_endpoint_independent_mapping=content.get(
            "enable_endpoint_independent_mapping"
        ),
        initial_nat_ips=content.get("initial_nat_ips"),
        icmp_idle_timeout_sec=content.get("icmp_idle_timeout_sec"),
        name=content["nat"],
        max_ports_per_vm=content.get("max_ports_per_vm"),
        min_ports_per_vm=content.get("min_ports_per_vm"),
        # list(gcp.compute.RouterNatSubnetworkArgs()
        nat64_subnetworks=content.get("nat64_subnetworks"),
        nat_ip_allocate_option=content.get("nat_ip_allocate_option"),
        nat_ips=content.get("nat_ips"),
        project=GCP_PROJECT,
        region=content.get("location", GCP_REGION),
        router=content.get("router"),
        source_subnetwork_ip_ranges_to_nat=content.get(
            "source_subnetwork_ip_ranges_to_nat"
        ),
        source_subnetwork_ip_ranges_to_nat64=content.get(
            "source_subnetwork_ip_ranges_to_nat64"
        ),
        tcp_established_idle_timeout_sec=content.get(
            "tcp_established_idle_timeout_sec"
        ),
        tcp_time_wait_timeout_sec=content.get("tcp_time_wait_timeout_sec"),
        tcp_transitory_idle_timeout_sec=content.get("tcp_transitory_idle_timeout_sec"),
        type=content.get("type"),
        udp_idle_timeout_sec=content.get("udp_idle_timeout_sec"),
        # gcp.compute.RouterNatLogConfigArgs()
        log_config=content.get("log_config"),
        # list(gcp.compute.RouterNatRuleArgs())
        rules=content.get("rules"),
        # list(gcp.compute.RouterSubnetworkArgs())
        subnetworks=content.get("subnetworks"),
        opts=opts,
    )

    return nat


def create_cloud_nat(
    template_vars: dict[str, str],
    opts: pulumi.ResourceOptions | None = None,
    json_files: list[dict[str, Any]] | None = None,
) -> Any:
    """
    Create cloud NAT Gateways and Routers based on JSON configuration files.
    Files should be at root: infra/gcp/auto/cloud_nat/<any>.json

    Args:
        template_vars: Template variables for substitution
        opts: Pulumi resource options (opcional)
        json_files: (opcional) Loaded JSON files list for local tests.
            If None, use read_json_files(...) from SRC_INFRA_PATH.

    Returns:
        Dictionary of created cloud NAT Gateways and Routers resources
    """
    # 1) Read JSONs (with variable substitution)
    if json_files is None:
        files = read_json_files(
            source_path=f"{SRC_INFRA_PATH}/gcp/auto/cloud_nat_gateway/",
            files_regex="**",
            template_vars=template_vars,
        )
    else:
        files = json_files

    # 2) Validate files and create resources
    routers: list[Any] = []
    nats: list[Any] = []
    for entry in files:
        content = entry.get("content", {}) or {}

        # 2.1) Validate files
        validate_entries(entries=[entry], schema=gcp_cloud_nat_gateway)

        # 2.2) Create resources in dependency order
        # -------- Router --------
        if content.get("router"):
            router = _create_router(entry, opts)
            routers.append(router)

        # -------- NAT Gateways --------
        # Depends on: Router
        nat_opts = pulumi.ResourceOptions(depends_on=routers)
        if opts:
            nat_opts = pulumi.ResourceOptions.merge(opts, nat_opts)
        if content.get("nat"):
            nat = _create_nat(entry, nat_opts)
            nats.append(nat)

    return {
        "routers": routers,
        "nats": nats,
    }
