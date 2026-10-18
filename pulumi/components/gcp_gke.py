# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

"""
GCP Kubernetes Engine (GKE) component.
Converted from terraform/gcp_k8s_engine.tf and modules/gcp/k8s_engine
"""

from __future__ import annotations

from typing import Any

import pulumi_gcp as gcp
from utils.json_reader import read_json_files
from variables import GCP_PROJECT, GCP_REGION, SRC_INFRA_PATH

import pulumi


def create_gke_clusters(  # noqa: PLR0912, PLR0915
    template_vars: dict[str, str],
    opts: pulumi.ResourceOptions | None = None,
    json_files: list[dict[str, Any]] | None = None,
) -> dict[str, Any]:
    """
    Create GKE (Google Kubernetes Engine) clusters and node pools based on JSON configuration files.
    Files should be at root: infra/gcp/auto/cloud_scheduler/<any>.json

    Args:
        template_vars: Template variables for substitution
        opts: Pulumi resource options (opcional)
        json_files: (opcional) Loaded JSON files list for local tests.
            If None, use read_json_files(...) from SRC_INFRA_PATH.

    Returns:
        Dictionary with created GKE clusters and node pools
    """
    # 1) Read JSONs (with variable substitution)
    if json_files is None:
        files = read_json_files(
            source_path=f"{SRC_INFRA_PATH}/gcp/auto/k8s_engine/",
            files_regex="**",
            template_vars=template_vars,
        )
    else:
        files = json_files

    # 2) Validate files and create resources
    clusters: list[Any] = []
    node_pools: list[Any] = []
    for entry in files:
        content = entry.get("content", {}) or {}
        source = entry["source"]

        # Create GKE Cluster
        if content.get("cluster_name"):
            cluster_args = {
                "name": content["cluster_name"],
                "project": GCP_PROJECT,
                "location": content.get("location", GCP_REGION),
                "description": content.get("description"),
                "initial_node_count": content.get("initial_node_count", 1),
                "remove_default_node_pool": content.get(
                    "remove_default_node_pool", True
                ),
                "deletion_protection": content.get("deletion_protection", False),
                "enable_autopilot": content.get("enable_autopilot"),
                "enable_kubernetes_alpha": content.get("enable_kubernetes_alpha"),
                "enable_legacy_abac": content.get("enable_legacy_abac"),
                "enable_shielded_nodes": content.get("enable_shielded_nodes"),
                "enable_tpu": content.get("enable_tpu"),
                "min_master_version": content.get("min_master_version"),
                "networking_mode": content.get("networking_mode"),
                "resource_labels": content.get("resource_labels"),
            }

            # Network configuration
            if content.get("network"):
                cluster_args["network"] = content["network"]

            if content.get("subnetwork"):
                cluster_args["subnetwork"] = content["subnetwork"]

            # Add IP allocation policy
            if content.get("ip_allocation_policy"):
                cluster_args["ip_allocation_policy"] = (
                    gcp.container.ClusterIpAllocationPolicyArgs(
                        **content["ip_allocation_policy"]
                    )
                )

            # Add private cluster config
            if content.get("private_cluster_config"):
                cluster_args["private_cluster_config"] = (
                    gcp.container.ClusterPrivateClusterConfigArgs(
                        **content["private_cluster_config"]
                    )
                )

            # Add master authorized networks config
            if content.get("master_authorized_networks_config"):
                cluster_args["master_authorized_networks_config"] = (
                    gcp.container.ClusterMasterAuthorizedNetworksConfigArgs(
                        **content["master_authorized_networks_config"]
                    )
                )

            # Add addons config
            if content.get("addons_config"):
                cluster_args["addons_config"] = gcp.container.ClusterAddonsConfigArgs(
                    **content["addons_config"]
                )

            # Add network policy
            if content.get("network_policy"):
                cluster_args["network_policy"] = gcp.container.ClusterNetworkPolicyArgs(
                    **content["network_policy"]
                )

            # Add maintenance policy
            if content.get("maintenance_policy"):
                cluster_args["maintenance_policy"] = (
                    gcp.container.ClusterMaintenancePolicyArgs(
                        **content["maintenance_policy"]
                    )
                )

            # Add workload identity config
            if content.get("workload_identity_config"):
                cluster_args["workload_identity_config"] = (
                    gcp.container.ClusterWorkloadIdentityConfigArgs(
                        **content["workload_identity_config"]
                    )
                )

            # Add binary authorization
            if content.get("binary_authorization"):
                cluster_args["binary_authorization"] = (
                    gcp.container.ClusterBinaryAuthorizationArgs(
                        **content["binary_authorization"]
                    )
                )

            # Add database encryption
            if content.get("database_encryption"):
                cluster_args["database_encryption"] = (
                    gcp.container.ClusterDatabaseEncryptionArgs(
                        **content["database_encryption"]
                    )
                )

            # Add release channel
            if content.get("release_channel"):
                cluster_args["release_channel"] = (
                    gcp.container.ClusterReleaseChannelArgs(
                        **content["release_channel"]
                    )
                )

            # Add monitoring config
            if content.get("monitoring_config"):
                cluster_args["monitoring_config"] = (
                    gcp.container.ClusterMonitoringConfigArgs(
                        **content["monitoring_config"]
                    )
                )

            # Add logging config
            if content.get("logging_config"):
                cluster_args["logging_config"] = gcp.container.ClusterLoggingConfigArgs(
                    **content["logging_config"]
                )

            cluster = gcp.container.Cluster(
                f"gke_cluster_{source}",
                **{k: v for k, v in cluster_args.items() if v is not None},
                opts=opts,
            )
            clusters.append(cluster)

            # Create Node Pools
            if content.get("node_pools"):
                for i, pool_config in enumerate(content["node_pools"]):
                    pool_args = {
                        "name": pool_config.get("name"),
                        "cluster": cluster.name,
                        "project": GCP_PROJECT,
                        "location": content.get("location", GCP_REGION),
                        "initial_node_count": pool_config.get("initial_node_count"),
                        "version": pool_config.get("version"),
                    }

                    # Add autoscaling
                    if pool_config.get("autoscaling"):
                        pool_args["autoscaling"] = (
                            gcp.container.NodePoolAutoscalingArgs(
                                **pool_config["autoscaling"]
                            )
                        )

                    # Add management
                    if pool_config.get("management"):
                        pool_args["management"] = gcp.container.NodePoolManagementArgs(
                            **pool_config["management"]
                        )

                    # Add node config
                    if pool_config.get("node_config"):
                        pool_args["node_config"] = gcp.container.NodePoolNodeConfigArgs(
                            **pool_config["node_config"]
                        )

                    # Add upgrade settings
                    if pool_config.get("upgrade_settings"):
                        pool_args["upgrade_settings"] = (
                            gcp.container.NodePoolUpgradeSettingsArgs(
                                **pool_config["upgrade_settings"]
                            )
                        )

                    # Add network config
                    if pool_config.get("network_config"):
                        pool_args["network_config"] = (
                            gcp.container.NodePoolNetworkConfigArgs(
                                **pool_config["network_config"]
                            )
                        )

                    node_pool = gcp.container.NodePool(
                        f"gke_node_pool_{source}_{i}",
                        **{k: v for k, v in pool_args.items() if v is not None},
                        opts=pulumi.ResourceOptions(parent=cluster),
                    )
                    node_pools.append(node_pool)

    return {
        "clusters": clusters,
        "node_pools": node_pools,
    }
