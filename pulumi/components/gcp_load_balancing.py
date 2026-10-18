# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

"""
GCP Cloud Load Balancing component.
References:
https://www.pulumi.com/registry/packages/gcp/api-docs/compute/
https://www.pulumi.com/registry/packages/gcp/api-docs/compute/healthcheck/
https://www.pulumi.com/registry/packages/gcp/api-docs/compute/backendservice/
https://www.pulumi.com/registry/packages/gcp/api-docs/compute/targethttpproxy/
https://www.pulumi.com/registry/packages/gcp/api-docs/compute/targethttpsproxy/
https://www.pulumi.com/registry/packages/gcp/api-docs/compute/targettcpproxy/
https://www.pulumi.com/registry/packages/gcp/api-docs/compute/targetsslproxy/
https://www.pulumi.com/registry/packages/gcp/api-docs/compute/forwardingrule/
https://www.pulumi.com/registry/packages/gcp/api-docs/compute/globalforwardingrule/
https://www.pulumi.com/registry/packages/gcp/api-docs/compute/regionurlmap/
https://www.pulumi.com/registry/packages/gcp/api-docs/compute/urlmap/
https://www.pulumi.com/registry/packages/gcp/api-docs/compute/instancegroup/
https://www.pulumi.com/registry/packages/gcp/api-docs/compute/globalnetworkendpoint/
https://www.pulumi.com/registry/packages/gcp/api-docs/compute/regionnetworkendpointgroup/
https://www.pulumi.com/registry/packages/gcp/api-docs/compute/networkendpointgroup/
"""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any

import pulumi_gcp as gcp
from utils.json_reader import read_json_files, slugify
from utils.schemas import gcp_load_balancing
from utils.validations import validate_entries
from variables import GCP_PROJECT, GCP_REGION, SRC_INFRA_PATH

import pulumi


def _to_self_link(value: str | None) -> str | None:
    """
    Normaliza IDs (nome, 'projects/...', ou self-link) para self-link completo.
    """
    api_base = "https://www.googleapis.com/compute/v1/"

    if not value:
        return None
    if value.startswith("https://"):
        return value
    if value.startswith("projects/"):
        return f"{api_base}{value}"

    return value


def _create_health_check(
    entry: dict[str, Any],
    opts: pulumi.ResourceOptions | None = None,
) -> Any:
    """Create Health Check based on entry."""
    content = entry.get("content", {}) or {}

    grpc_health_check = content.get("grpc_health_check", {}) or {}
    http_health_check = content.get("http_health_check", {}) or {}
    http2_health_check = content.get("http2_health_check", {}) or {}
    https_health_check = content.get("https_health_check", {}) or {}
    log_config = content.get("log_config", {}) or {}
    ssl_health_check = content.get("ssl_health_check", {}) or {}
    tcp_health_check = content.get("tcp_health_check", {}) or {}

    return gcp.compute.HealthCheck(
        resource_name=f"health_check_{slugify(entry['file_name'])}",
        check_interval_sec=content.get("check_interval_sec"),
        description=content.get("health_check_description"),
        healthy_threshold=content.get("healthy_threshold"),
        grpc_health_check=gcp.compute.HealthCheckGrpcHealthCheckArgs(
            grpc_service_name=grpc_health_check.get("grpc_service_name"),
            port=grpc_health_check.get("port"),
            port_name=grpc_health_check.get("port_name"),
            port_specification=grpc_health_check.get("port_specification"),
        )
        if grpc_health_check
        else None,
        http_health_check=gcp.compute.HealthCheckHttpHealthCheckArgs(
            host=http_health_check.get("host"),
            port=http_health_check.get("port"),
            port_name=http_health_check.get("port_name"),
            port_specification=http_health_check.get("port_specification"),
            proxy_header=http_health_check.get("proxy_header"),
            request_path=http_health_check.get("request_path"),
            response=http_health_check.get("response"),
        )
        if http_health_check
        else None,
        http2_health_check=gcp.compute.HealthCheckHttp2HealthCheckArgs(
            host=http2_health_check.get("host"),
            port=http2_health_check.get("port"),
            port_name=http2_health_check.get("port_name"),
            port_specification=http2_health_check.get("port_specification"),
            proxy_header=http2_health_check.get("proxy_header"),
            request_path=http2_health_check.get("request_path"),
            response=http2_health_check.get("response"),
        )
        if http2_health_check
        else None,
        https_health_check=gcp.compute.HealthCheckHttpsHealthCheckArgs(
            host=https_health_check.get("host"),
            port=https_health_check.get("port"),
            port_name=https_health_check.get("port_name"),
            port_specification=https_health_check.get("port_specification"),
            proxy_header=https_health_check.get("proxy_header"),
            request_path=https_health_check.get("request_path"),
            response=https_health_check.get("response"),
        )
        if https_health_check
        else None,
        log_config=gcp.compute.HealthCheckLogConfigArgs(enable=log_config.get("enable"))
        if log_config
        else None,
        name=content.get("health_check"),
        project=GCP_PROJECT,
        source_regions=content.get("source_regions"),
        ssl_health_check=gcp.compute.HealthCheckSslHealthCheckArgs(
            port=ssl_health_check.get("port"),
            port_name=ssl_health_check.get("port_name"),
            port_specification=ssl_health_check.get("port_specification"),
            proxy_header=ssl_health_check.get("proxy_header"),
            request=ssl_health_check.get("request"),
            response=ssl_health_check.get("response"),
        )
        if ssl_health_check
        else None,
        tcp_health_check=gcp.compute.HealthCheckTcpHealthCheckArgs(
            port=tcp_health_check.get("port"),
            port_name=tcp_health_check.get("port_name"),
            port_specification=tcp_health_check.get("port_specification"),
            proxy_header=tcp_health_check.get("proxy_header"),
            request=tcp_health_check.get("request"),
            response=tcp_health_check.get("response"),
        )
        if tcp_health_check
        else None,
        timeout_sec=content.get("health_check_timeout_sec"),
        unhealthy_threshold=content.get("unhealthy_threshold"),
        opts=opts,
    )


def _create_instance_group(
    i: int,
    config: dict[str, Any],
    entry: dict[str, Any],
    opts: pulumi.ResourceOptions | None = None,
) -> Any:
    """Create Instance Group based on entry."""
    content = entry.get("content", {}) or {}
    return gcp.compute.InstanceGroup(
        resource_name=f"instance_group_{slugify(entry['file_name'])}_{i}",
        description=config.get("instance_group_description"),
        instances=config.get("instances", []),
        name=config.get("instance_group"),
        named_ports=[
            gcp.compute.InstanceGroupNamedPortArgs(
                name=port.get("name"), port=port.get("port")
            )
            for port in config.get("named_port", [])
        ]
        if config.get("named_port")
        else None,
        network=content.get("network"),
        project=GCP_PROJECT,
        zone=content.get("zone", f"{GCP_REGION}-b"),
        opts=opts,
    )


def _create_global_neg(
    i: int,
    config: dict[str, Any],
    entry: dict[str, Any],
    opts: pulumi.ResourceOptions | None = None,
) -> gcp.compute.GlobalNetworkEndpointGroup:
    """Create a Global Network Endpoint Group."""
    return gcp.compute.GlobalNetworkEndpointGroup(
        resource_name=f"neg_{slugify(entry['file_name'])}_{i}",
        default_port=config.get("port"),
        description=config.get("description"),
        network_endpoint_type=config.get("network_endpoint_type"),
        project=GCP_PROJECT,
        opts=opts,
    )


def _create_regional_neg(
    i: int,
    config: dict[str, Any],
    entry: dict[str, Any],
    opts: pulumi.ResourceOptions | None = None,
) -> gcp.compute.RegionNetworkEndpointGroup:
    """Create a Regional Network Endpoint Group."""
    app_engine = config.get("app_engine")
    cloud_function = config.get("cloud_function")
    cloud_run = config.get("cloud_run")
    psc_data = config.get("psc_data")
    serverless_deployment = config.get("serverless_deployment")

    return gcp.compute.RegionNetworkEndpointGroup(
        resource_name=f"neg_{slugify(entry['file_name'])}_{i}",
        app_engine=gcp.compute.RegionNetworkEndpointGroupAppEngineArgs(
            service=app_engine.get("service"),
            url_mask=app_engine.get("url_mask"),
            version=app_engine.get("version"),
        )
        if app_engine
        else None,
        cloud_function=gcp.compute.RegionNetworkEndpointGroupCloudFunctionArgs(
            function=cloud_function.get("function"),
            url_mask=cloud_function.get("url_mask"),
        )
        if cloud_function
        else None,
        cloud_run=gcp.compute.RegionNetworkEndpointGroupCloudRunArgs(
            service=cloud_run.get("service"),
            tag=cloud_run.get("tag"),
            url_mask=cloud_run.get("url_mask"),
        )
        if cloud_run
        else None,
        description=config.get("neg_description"),
        name=config.get("neg"),
        network=config.get("network"),
        network_endpoint_type=config.get("network_endpoint_type"),
        project=GCP_PROJECT,
        psc_data=gcp.compute.RegionNetworkEndpointGroupPscDataArgs(
            producer_port=psc_data.get("producer_port"),
        )
        if psc_data
        else None,
        psc_target_service=config.get("psc_target_service"),
        region=config.get("location", GCP_REGION),
        serverless_deployment=gcp.compute.RegionNetworkEndpointGroupServerlessDeploymentArgs(
            platform=serverless_deployment.get("platform"),
            resource=serverless_deployment.get("resource"),
            url_mask=serverless_deployment.get("url_mask"),
            version=serverless_deployment.get("version"),
        )
        if serverless_deployment
        else None,
        subnetwork=config.get("subnetwork"),
        opts=opts,
    )


def _create_zonal_neg(
    i: int,
    config: dict[str, Any],
    entry: dict[str, Any],
    opts: pulumi.ResourceOptions | None = None,
) -> gcp.compute.NetworkEndpointGroup:
    """Create a Zonal Network Endpoint Group."""
    return gcp.compute.NetworkEndpointGroup(
        resource_name=f"neg_{slugify(entry['file_name'])}_{i}",
        default_port=config.get("default_port"),
        description=config.get("neg_description"),
        name=config.get("neg"),
        network=config.get("network"),
        network_endpoint_type=config.get("network_endpoint_type"),
        project=GCP_PROJECT,
        subnetwork=config.get("subnetwork"),
        zone=config.get("zone", f"{GCP_REGION}-b"),
        opts=opts,
    )


def _create_neg(
    i: int,
    config: dict[str, Any],
    entry: dict[str, Any],
    opts: pulumi.ResourceOptions | None = None,
) -> Any:
    """Create Network Endpoint Group based on entry."""
    neg_type = config.get("neg_type")
    if neg_type == "global":
        return _create_global_neg(i, config, entry, opts)
    if neg_type == "regional":
        return _create_regional_neg(i, config, entry, opts)
    return _create_zonal_neg(i, config, entry, opts)


def _create_regional_backend(
    i: int,
    config: dict[str, Any],
    entry: dict[str, Any],
    backend_args: dict[str, Any],
    opts: pulumi.ResourceOptions | None = None,
) -> gcp.compute.RegionBackendService:
    """Create a Regional Backend Service."""
    content = entry.get("content", {}) or {}
    backend_args["network"] = content.get("network")
    backend_args["region"] = content.get("location", GCP_REGION)

    if config.get("backend"):
        backend_args["backend"] = [
            gcp.compute.RegionBackendServiceBackendArgs(**config["backend"])
        ]
    if config.get("cdn_policy"):
        backend_args["cdn_policy"] = gcp.compute.RegionBackendServiceCdnPolicyArgs(
            **config["cdn_policy"]
        )
    if config.get("circuit_breakers"):
        backend_args["circuit_breakers"] = (
            gcp.compute.RegionBackendServiceCircuitBreakersArgs(
                **config["circuit_breakers"]
            )
        )
    if config.get("connection_tracking_policy"):
        backend_args["connection_tracking_policy"] = (
            gcp.compute.RegionBackendServiceConnectionTrackingPolicyArgs(
                **config["connection_tracking_policy"]
            )
        )
    if config.get("consistent_hash"):
        backend_args["consistent_hash"] = (
            gcp.compute.RegionBackendServiceConsistentHashArgs(
                **config["consistent_hash"]
            )
        )
    if config.get("iap"):
        backend_args["iap"] = gcp.compute.RegionBackendServiceIapArgs(**config["iap"])
    if config.get("log_config"):
        backend_args["log_config"] = gcp.compute.RegionBackendServiceLogConfigArgs(
            **config["backend_log_config"]
        )

    return gcp.compute.RegionBackendService(
        resource_name=f"backend_service_{slugify(entry['file_name'])}_{i}",
        **{k: v for k, v in backend_args.items() if v is not None},
        opts=opts,
    )


def _create_global_backend(
    i: int,
    config: dict[str, Any],
    entry: dict[str, Any],
    backend_args: dict[str, Any],
    opts: pulumi.ResourceOptions | None = None,
) -> gcp.compute.BackendService:
    """Create a Global Backend Service."""
    content = entry.get("content", {}) or {}
    backend_args["compression_mode"] = content.get("compression_mode")
    backend_args["custom_request_headers"] = content.get("custom_request_headers")
    backend_args["custom_response_headers"] = content.get("custom_response_headers")
    backend_args["edge_security_policy"] = content.get("edge_security_policy")

    if config.get("backend"):
        backend_args["backends"] = [
            gcp.compute.BackendServiceBackendArgs(**config["backend"])
        ]
    if config.get("cdn_policy"):
        backend_args["cdn_policy"] = gcp.compute.BackendServiceCdnPolicyArgs(
            **config["cdn_policy"]
        )
    if config.get("iap"):
        backend_args["iap"] = gcp.compute.BackendServiceIapArgs(**config["iap"])
    if config.get("log_config"):
        backend_args["log_config"] = gcp.compute.BackendServiceLogConfigArgs(
            **config["log_config"]
        )

    return gcp.compute.BackendService(
        resource_name=f"backend_service_{slugify(entry['file_name'])}_{i}",
        **{k: v for k, v in backend_args.items() if v is not None},
        opts=opts,
    )


def _create_backend(
    i: int,
    config: dict[str, Any],
    entry: dict[str, Any],
    opts: pulumi.ResourceOptions | None = None,
) -> Any:
    """Create Backend Service based on entry."""
    backend_type = config.get("backend_type", "global")
    health_checks_value = config.get("health_checks")

    final_health_checks = health_checks_value
    if health_checks_value and len(health_checks_value) == 1:
        final_health_checks = health_checks_value[0]

    backend_args = {
        "affinity_cookie_ttl_sec": config.get("affinity_cookie_ttl_sec"),
        "connection_draining_timeout_sec": config.get(
            "connection_draining_timeout_sec"
        ),
        "description": config.get("backend_description"),
        "enable_cdn": config.get("enable_cdn"),
        "health_checks": final_health_checks,
        "load_balancing_scheme": config.get("backend_load_balancing_scheme"),
        "name": config.get("backend_name"),
        "project": GCP_PROJECT,
        "protocol": config.get("protocol"),
        "security_policy": config.get("security_policy"),
        "session_affinity": config.get("session_affinity"),
        "timeout_sec": config.get("timeout_sec"),
    }

    if backend_type == "regional":
        return _create_regional_backend(i, config, entry, backend_args, opts)

    return _create_global_backend(i, config, entry, backend_args, opts)


def _create_regional_url_map(
    entry: dict[str, Any],
    url_map_args: dict[str, Any],
    opts: pulumi.ResourceOptions | None = None,
) -> Any:
    """Create a Regional URL Map."""
    content = entry.get("content", {}) or {}
    url_map_args["region"] = content.get("location", GCP_REGION)

    if content.get("default_route_action"):
        url_map_args["default_route_action"] = (
            gcp.compute.RegionUrlMapDefaultRouteActionArgs(
                **content["default_route_action"]
            )
        )
        url_map_args["host_rules"] = [
            gcp.compute.RegionUrlMapHostRuleArgs(**rule)
            for rule in content["host_rules"]
        ]
    if content.get("path_matchers"):
        url_map_args["path_matchers"] = [
            gcp.compute.RegionUrlMapPathMatcherArgs(**path)
            for path in content["path_matchers"]
        ]

    return gcp.compute.RegionUrlMap(
        resource_name=f"url_map_{slugify(entry['file_name'])}",
        **{k: v for k, v in url_map_args.items() if v is not None},
        opts=opts,
    )


def _create_global_url_map(
    entry: dict[str, Any],
    url_map_args: dict[str, Any],
    opts: pulumi.ResourceOptions | None = None,
) -> gcp.compute.URLMap:
    """Create a Global URL Map."""
    content = entry.get("content", {}) or {}
    if content.get("host_rules"):
        url_map_args["host_rules"] = [
            gcp.compute.URLMapHostRuleArgs(**rule) for rule in content["host_rules"]
        ]
        url_map_args["path_matchers"] = [
            gcp.compute.URLMapPathMatcherArgs(**path)
            for path in content["path_matchers"]
        ]

    return gcp.compute.URLMap(
        resource_name=f"url_map_{slugify(entry['file_name'])}",
        **{k: v for k, v in url_map_args.items() if v is not None},
        opts=opts,
    )


def _create_url_map(
    entry: dict[str, Any],
    opts: pulumi.ResourceOptions | None = None,
) -> Any:
    """Create Url Map based on entry."""
    content = entry.get("content", {}) or {}
    url_map_type = content.get("url_map_type", "global")

    url_map_args = {
        "default_service": content.get("default_service"),
        "description": content.get("url_map_description"),
        "name": content.get("url_map"),
        "project": GCP_PROJECT,
    }

    if url_map_type == "regional":
        return _create_regional_url_map(entry, url_map_args, opts)

    return _create_global_url_map(entry, url_map_args, opts)


def _create_http_proxy(
    entry: dict[str, Any],
    proxy_args: dict[str, Any],
    opts: pulumi.ResourceOptions | None = None,
) -> gcp.compute.TargetHttpProxy:
    """Create a Target HTTP Proxy."""
    content = entry.get("content", {}) or {}
    proxy_args["http_keep_alive_timeout_sec"] = content.get(
        "http_keep_alive_timeout_sec"
    )
    proxy_args["url_map"] = content.get("url_map")
    return gcp.compute.TargetHttpProxy(
        resource_name=f"proxy_{slugify(entry['file_name'])}",
        **{k: v for k, v in proxy_args.items() if v is not None},
        opts=opts,
    )


def _create_https_proxy(
    entry: dict[str, Any],
    proxy_args: dict[str, Any],
    opts: pulumi.ResourceOptions | None = None,
) -> gcp.compute.TargetHttpsProxy:
    """Create a Target HTTPS Proxy."""
    content = entry.get("content", {}) or {}
    proxy_args.update(
        {
            "certificate_manager_certificates": content.get(
                "certificate_manager_certificates"
            ),
            "certificate_map": content.get("certificate_map"),
            "http_keep_alive_timeout_sec": content.get("http_keep_alive_timeout_sec"),
            "quic_override": content.get("quic_override"),
            "server_tls_policy": content.get("server_tls_policy"),
            "ssl_certificates": content.get("ssl_certificates"),
            "ssl_policy": content.get("ssl_policy"),
            "tls_early_data": content.get("tls_early_data"),
            "url_map": content.get("url_map"),
        }
    )
    return gcp.compute.TargetHttpsProxy(
        resource_name=f"proxy_{slugify(entry['file_name'])}",
        **{k: v for k, v in proxy_args.items() if v is not None},
        opts=opts,
    )


def _create_tcp_proxy(
    entry: dict[str, Any],
    proxy_args: dict[str, Any],
    opts: pulumi.ResourceOptions | None = None,
) -> gcp.compute.TargetTCPProxy:
    """Create a Target TCP Proxy."""
    content = entry.get("content", {}) or {}
    proxy_args["backend_service"] = content.get("backend_service")
    proxy_args["proxy_header"] = content.get("proxy_header")
    return gcp.compute.TargetTCPProxy(
        resource_name=f"proxy_{slugify(entry['file_name'])}",
        **{k: v for k, v in proxy_args.items() if v is not None},
        opts=opts,
    )


def _create_ssl_proxy(
    entry: dict[str, Any],
    proxy_args: dict[str, Any],
    opts: pulumi.ResourceOptions | None = None,
) -> gcp.compute.TargetSSLProxy:
    """Create a Target SSL Proxy."""
    content = entry.get("content", {}) or {}
    proxy_args.update(
        {
            "backend_service": content.get("backend_service"),
            "certificate_map": content.get("certificate_map"),
            "proxy_header": content.get("proxy_header"),
            "ssl_certificates": content.get("ssl_certificates"),
            "ssl_policy": content.get("ssl_policy"),
        }
    )
    return gcp.compute.TargetSSLProxy(
        resource_name=f"proxy_{slugify(entry['file_name'])}",
        **{k: v for k, v in proxy_args.items() if v is not None},
        opts=opts,
    )


def _create_proxy(
    entry: dict[str, Any],
    opts: pulumi.ResourceOptions | None = None,
) -> Any:
    """Create Proxy based on entry."""
    content = entry.get("content", {}) or {}
    proxy_type = content.get("proxy_type", "https")
    proxy_args = {
        "description": content.get("proxy_description"),
        "name": content.get("proxy"),
        "project": GCP_PROJECT,
        "proxy_bind": content.get("proxy_bind"),
    }
    if proxy_type == "http":
        return _create_http_proxy(entry, proxy_args, opts)
    if proxy_type == "https":
        return _create_https_proxy(entry, proxy_args, opts)
    if proxy_type == "tcp":
        return _create_tcp_proxy(entry, proxy_args, opts)
    if proxy_type == "ssl":
        return _create_ssl_proxy(entry, proxy_args, opts)
    return None


def _create_regional_forwarding_rule(
    entry: dict[str, Any],
    fr_args: dict[str, Any],
    opts: pulumi.ResourceOptions | None = None,
) -> gcp.compute.ForwardingRule:
    """Create a Regional Forwarding Rule."""
    content = entry.get("content", {}) or {}
    fr_args.update(
        {
            "all_ports": content.get("all_ports"),
            "allow_global_access": content.get("allow_global_access"),
            "backend_service": content.get("backend_service"),
            "ip_collection": content.get("ip_collection"),
            "is_mirroring_collector": content.get("is_mirroring_collector"),
            "ports": content.get("ports"),
            "recreate_closed_psc": content.get("recreate_closed_psc"),
            "region": content.get("location", GCP_REGION),
            "service_label": content.get("service_label"),
        }
    )
    return gcp.compute.ForwardingRule(
        resource_name=f"forwarding_rule_{slugify(entry['file_name'])}",
        **{k: v for k, v in fr_args.items() if v is not None},
        opts=opts,
    )


def _create_global_forwarding_rule(
    entry: dict[str, Any],
    fr_args: dict[str, Any],
    opts: pulumi.ResourceOptions | None = None,
) -> gcp.compute.GlobalForwardingRule:
    """Create a Global Forwarding Rule."""
    content = entry.get("content", {}) or {}
    fr_args.update(
        {
            "external_managed_backend_bucket_migration_state": content.get(
                "external_managed_backend_bucket_migration_state"
            ),
            "external_managed_backend_bucket_migration_testing_percentage": content.get(
                "external_managed_backend_backend_bucket_migration_testing_percentage"
            ),
            "metadata_filters": content.get("metadata_filters"),
        }
    )
    return gcp.compute.GlobalForwardingRule(
        resource_name=f"forwarding_rule_{slugify(entry['file_name'])}",
        **{k: v for k, v in fr_args.items() if v is not None},
        opts=opts,
    )


def _create_forwarding_rule(
    entry: dict[str, Any],
    opts: pulumi.ResourceOptions | None = None,
) -> Any:
    """Create Forwarding Rule based on entry."""
    content = entry.get("content", {}) or {}
    fr_type = content.get("forwarding_rule_type")
    fr_args = {
        "allow_psc_global_access": content.get("allow_psc_global_access"),
        "description": content.get("forwarding_rule_description"),
        "ip_address": content.get("ip_address"),
        "ip_protocol": content.get("ip_protocol"),
        "ip_version": content.get("ip_version"),
        "labels": content.get("forwarding_rule_labels"),
        "load_balancing_scheme": content.get("forwarding_rule_load_balancing_scheme"),
        "name": content.get("forwarding_rule"),
        "network": content.get("network"),
        "network_tier": content.get("network_tier"),
        "no_automate_dns_zone": content.get("no_automate_dns_zone"),
        "port_range": content.get("port_range"),
        "project": GCP_PROJECT,
        "service_directory_registrations": content.get(
            "service_directory_registrations"
        ),
        "source_ip_ranges": content.get("source_ip_ranges"),
        "subnetwork": content.get("subnetwork"),
        "target": content.get("target"),
    }
    if fr_type == "regional":
        return _create_regional_forwarding_rule(entry, fr_args, opts)
    return _create_global_forwarding_rule(entry, fr_args, opts)


@dataclass
class LBRegistry:
    """Registry to hold load balancing resources."""

    health_checks: list[Any] = field(default_factory=list)
    instance_groups: list[Any] = field(default_factory=list)
    negs: list[Any] = field(default_factory=list)
    backend_services: list[Any] = field(default_factory=list)
    url_maps: list[Any] = field(default_factory=list)
    proxies: list[Any] = field(default_factory=list)
    forwarding_rules: list[Any] = field(default_factory=list)

    def all_deps(self) -> list[Any]:
        """Return all created resources as a flat list."""
        return (
            self.health_checks
            + self.instance_groups
            + self.negs
            + self.backend_services
            + self.url_maps
            + self.proxies
            + self.forwarding_rules
        )


def create_load_balancing(
    template_vars: dict[str, str],
    opts: pulumi.ResourceOptions | None = None,
    json_files: list[dict[str, Any]] | None = None,
) -> dict[str, Any]:
    """
    Create Cloud Load Balancing resources based on JSON configuration files.
    Files should be at root: infra/gcp/auto/cloud_load_balancing/<any>.json

    Args:
        template_vars: Template variables for substitution
        opts: Pulumi resource options (opcional)
        json_files: (opcional) Loaded JSON files list for local tests.
            If None, use read_json_files(...) from SRC_INFRA_PATH.

    Returns:
        Dictionary with created Cloud Load Balancing resources
    """
    # 1) Read JSONs (with variable substitution)
    if json_files is None:
        files = read_json_files(
            source_path=f"{SRC_INFRA_PATH}/gcp/auto/cloud_load_balancing/",
            files_regex="**",
            template_vars=template_vars,
        )
    else:
        files = json_files

    # 2) Validate files and create resources
    registry = LBRegistry()
    for entry in files:
        _process_lb_entry(entry, opts, registry)

    return {
        "health_checks": registry.health_checks,
        "instance_groups": registry.instance_groups,
        "negs": registry.negs,
        "backend_services": registry.backend_services,
        "url_maps": registry.url_maps,
        "proxies": registry.proxies,
        "forwarding_rules": registry.forwarding_rules,
    }


def _process_lb_entry(
    entry: dict[str, Any],
    opts: pulumi.ResourceOptions | None,
    registry: LBRegistry,
) -> None:
    """Helper to process a single load balancing entry."""
    content = entry.get("content", {}) or {}
    validate_entries(entries=[entry], schema=gcp_load_balancing)

    _process_foundational_resources(entry, content, opts, registry)
    _process_backend_resources(entry, content, opts, registry)
    _process_routing_resources(entry, content, opts, registry)


def _process_foundational_resources(
    entry: dict[str, Any],
    content: dict[str, Any],
    opts: pulumi.ResourceOptions | None,
    registry: LBRegistry,
) -> None:
    """Process Health Checks, Instance Groups and NEGs."""
    if content.get("health_check"):
        registry.health_checks.append(_create_health_check(entry, opts))

    if content.get("instance_groups"):
        for i, config in enumerate(content.get("instance_groups", [])):
            registry.instance_groups.append(
                _create_instance_group(i, config, entry, opts)
            )

    if content.get("negs"):
        for i, config in enumerate(content.get("negs", [])):
            registry.negs.append(_create_neg(i, config, entry, opts))


def _process_backend_resources(
    entry: dict[str, Any],
    content: dict[str, Any],
    opts: pulumi.ResourceOptions | None,
    registry: LBRegistry,
) -> None:
    """Process Backend Services."""
    backend_deps = registry.health_checks + registry.instance_groups + registry.negs
    backend_opts = pulumi.ResourceOptions(depends_on=backend_deps)
    if opts:
        backend_opts = pulumi.ResourceOptions.merge(opts, backend_opts)

    if content.get("backend_services"):
        for i, config in enumerate(content.get("backend_services", [])):
            registry.backend_services.append(
                _create_backend(i, config, entry, backend_opts)
            )


def _process_routing_resources(
    entry: dict[str, Any],
    content: dict[str, Any],
    opts: pulumi.ResourceOptions | None,
    registry: LBRegistry,
) -> None:
    """Process URL Maps, Proxies and Forwarding Rules."""
    url_map_opts = pulumi.ResourceOptions(depends_on=registry.backend_services)
    if opts:
        url_map_opts = pulumi.ResourceOptions.merge(opts, url_map_opts)
    if content.get("url_map"):
        registry.url_maps.append(_create_url_map(entry, url_map_opts))

    proxy_deps = registry.backend_services + registry.url_maps
    proxy_opts = pulumi.ResourceOptions(depends_on=proxy_deps)
    if opts:
        proxy_opts = pulumi.ResourceOptions.merge(opts, proxy_opts)
    if content.get("proxy"):
        registry.proxies.append(_create_proxy(entry, proxy_opts))

    fr_opts = pulumi.ResourceOptions(depends_on=registry.proxies)
    if opts:
        fr_opts = pulumi.ResourceOptions.merge(opts, fr_opts)
    if content.get("forwarding_rule"):
        registry.forwarding_rules.append(_create_forwarding_rule(entry, fr_opts))
