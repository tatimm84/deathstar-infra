# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

"""
GCP Compute Engine component.
References:
https://www.pulumi.com/registry/packages/gcp/api-docs/compute/
https://www.pulumi.com/registry/packages/gcp/api-docs/compute/instance/
https://www.pulumi.com/registry/packages/gcp/api-docs/compute/resourcepolicy/
https://www.pulumi.com/registry/packages/gcp/api-docs/compute/diskresourcepolicyattachment/
"""

from __future__ import annotations

from typing import Any, cast

import pulumi_gcp as gcp
from utils.json_reader import read_json_files, slugify
from utils.schemas import gcp_compute_instances
from utils.validations import validate_entries
from variables import GCP_PROJECT, GCP_REGION, SRC_INFRA_PATH

import pulumi


def as_list(x) -> list:
    """Converte None/dict em lista. Se já for lista, retorna igual."""
    if x is None:
        return []
    return x if isinstance(x, list) else [x]


def create_compute_instances(
    template_vars: dict[str, str],
    opts: pulumi.ResourceOptions | None = None,
    json_files: list[dict[str, Any]] | None = None,
) -> dict[str, Any]:
    """
    Create Compute Engine instances based on JSON configuration files.
    Files should be at root: infra/gcp/auto/compute_engine/<any>.json

    Args:
        template_vars: Template variables for substitution
        opts: Pulumi resource options (opcional)
        json_files: (opcional) Loaded JSON files list for local tests.
            If None, use read_json_files(...) from SRC_INFRA_PATH.

    Returns:
        Dictionary of created Compute Engine instances
    """
    # 1) Read JSONs (with variable substitution)
    if json_files is None:
        files = read_json_files(
            source_path=f"{SRC_INFRA_PATH}/gcp/auto/compute_engine/",
            files_regex="**",
            template_vars=template_vars,
        )
    else:
        files = json_files

    # 2) Validate files, extract subdict with security and create resources
    instances: list[Any] = []
    policies: list[Any] = []
    attachments: list[Any] = []
    for entry in files:
        content = entry.get("content", {}) or {}
        machine_count = content.get("machine_count", 1)

        # 2.1) Validate files
        validate_entries(entries=[entry], schema=gcp_compute_instances)

        for i in range(machine_count):
            instance_name = (
                entry.get("file_name")
                if machine_count == 1
                else f"{entry.get('file_name')}-{i}"
            )

            # 2.2) Extract subdict with security and create resources
            # -------- Instances --------
            instance = gcp.compute.Instance(
                resource_name=f"compute_instance_{slugify(entry['file_name'])}_{i}",
                # gcp.compute.InstanceAdvancedMachineFeaturesArgs()
                advanced_machine_features=content.get("advanced_machine_features"),
                allow_stopping_for_update=content.get("allow_stopping_for_update"),
                # list(gcp.compute.InstanceAttachedDiskArgs())
                attached_disks=content.get("attached_disks"),
                # gcp.compute.InstanceBootDiskArgs()
                boot_disk=content.get("boot_disk"),
                can_ip_forward=content.get("can_ip_forward"),
                # gcp.compute.InstanceConfidentialInstanceConfigArgs()
                confidential_instance_config=content.get(
                    "confidential_instance_config"
                ),
                deletion_protection=content.get("deletion_protection"),
                description=content.get("description"),
                desired_status=content.get("desired_status"),
                enable_display=content.get("enable_display"),
                # list(gcp.compute.InstanceGuestAcceleratorArgs())
                guest_accelerators=content.get("guest_accelerators"),
                hostname=content.get("hostname"),
                labels=content.get("labels"),
                machine_type=content.get("machine_type"),
                metadata=content.get("metadata"),
                metadata_startup_script=content.get("metadata_startup_script"),
                min_cpu_platform=content.get("min_cpu_platform"),
                name=instance_name,
                # list(gcp.compute.InstanceNetworkInterfaceArgs())
                network_interfaces=content.get("network_interfaces"),
                # gcp.compute.InstanceNetworkPerformanceConfigArgs()
                network_performance_config=content.get("network_performance_config"),
                # gcp.compute.InstanceParamsArgs()
                params=content.get("params"),
                partner_metadata=content.get("partner_metadata"),
                project=GCP_PROJECT,
                # gcp.compute.InstanceReservationAffinityArgs()
                reservation_affinity=content.get("reservation_affinity"),
                resource_policies=content.get("resource_policies"),
                # gcp.compute.InstanceSchedulingArgs()
                scheduling=content.get("scheduling"),
                # list(gcp.compute.InstanceScratchDiskArgs())
                scratch_disks=content.get("scratch_disks"),
                # gcp.compute.InstanceServiceAccountArgs()
                service_account=content.get("service_account"),
                # gcp.compute.InstanceShieldedInstanceConfigArgs()
                shielded_instance_config=content.get("shielded_instance_config"),
                tags=content.get("tags"),
                zone=content.get("zone", f"{GCP_REGION}-b"),
                opts=opts,
            )
            instances.append(instance)

            # -------- Resource Policy --------
            dcp = content.get("disk_consistency_group_policy") or {}
            gpp = content.get("group_placement_policy") or {}
            isp = content.get("instance_schedule_policy") or {}
            ssp = content.get("snapshot_schedule_policy") or {}
            if isp or ssp or gpp or dcp:
                isp_vm_start = isp.get("vm_start_schedule")
                isp_vm_stop = isp.get("vm_stop_schedule")
                ssp_schedule = ssp.get("schedule") or {}
                ssp_daily = ssp_schedule.get("daily_schedule") or {}
                ssp_hourly = ssp_schedule.get("hourly_schedule") or {}
                ssp_weekly = ssp_schedule.get("weekly_schedule") or {}
                ssp_ret = ssp.get("retention_policy") or {}
                ssp_props = ssp.get("snapshot_properties") or {}

                # WORKAROUND: Pulumi serialization error
                # "Expected 'list' got '<class 'str'>'"
                # implies that the schema expects a string but we are passing a list.
                storage_locations = as_list(ssp_props.get("storage_locations"))
                final_storage_locations = None
                if storage_locations:
                    final_storage_locations = (
                        storage_locations[0]
                        if len(storage_locations) == 1
                        else storage_locations
                    )

                policy = gcp.compute.ResourcePolicy(
                    resource_name=f"compute_policy_{slugify(entry['file_name'])}_{i}",
                    description=content.get("schedule_description"),
                    disk_consistency_group_policy=gcp.compute.ResourcePolicyDiskConsistencyGroupPolicyArgs(
                        enabled=bool(dcp.get("enabled")),
                    )
                    if dcp
                    else None,
                    group_placement_policy=gcp.compute.ResourcePolicyGroupPlacementPolicyArgs(
                        availability_domain_count=gpp.get("availability_domain_count"),
                        collocation=gpp.get("collocation"),
                        max_distance=gpp.get("max_distance"),
                        vm_count=gpp.get("vm_count"),
                    )
                    if gpp
                    else None,
                    instance_schedule_policy=gcp.compute.ResourcePolicyInstanceSchedulePolicyArgs(
                        time_zone=str(isp.get("time_zone", "UTC")),
                        expiration_time=isp.get("expiration_time"),
                        start_time=isp.get("start_time"),
                        vm_start_schedule=(
                            gcp.compute.ResourcePolicyInstanceSchedulePolicyVmStartScheduleArgs(
                                schedule=isp_vm_start.get("schedule")
                            )
                            if isp_vm_start
                            else None
                        ),
                        vm_stop_schedule=(
                            gcp.compute.ResourcePolicyInstanceSchedulePolicyVmStopScheduleArgs(
                                schedule=isp_vm_stop.get("schedule")
                            )
                            if isp_vm_stop
                            else None
                        ),
                    )
                    if isp
                    else None,
                    snapshot_schedule_policy=gcp.compute.ResourcePolicySnapshotSchedulePolicyArgs(
                        schedule=cast(
                            Any,
                            gcp.compute.ResourcePolicySnapshotSchedulePolicyScheduleArgs(
                                daily_schedule=(
                                    gcp.compute.ResourcePolicySnapshotSchedulePolicyScheduleDailyScheduleArgs(
                                        days_in_cycle=int(
                                            ssp_daily.get("days_in_cycle", 1)
                                        ),
                                        start_time=str(
                                            ssp_daily.get("start_time", "00:00")
                                        ),
                                    )
                                    if ssp_daily
                                    else None
                                ),
                                hourly_schedule=(
                                    gcp.compute.ResourcePolicySnapshotSchedulePolicyScheduleHourlyScheduleArgs(
                                        hours_in_cycle=int(
                                            ssp_hourly.get("hours_in_cycle", 24)
                                        ),
                                        start_time=str(
                                            ssp_hourly.get("start_time", "00:00")
                                        ),
                                    )
                                    if ssp_hourly
                                    else None
                                ),
                                weekly_schedule=(
                                    gcp.compute.ResourcePolicySnapshotSchedulePolicyScheduleWeeklyScheduleArgs(
                                        day_of_weeks=[
                                            gcp.compute.ResourcePolicySnapshotSchedulePolicyScheduleWeeklyScheduleDayOfWeekArgs(
                                                day=dow.get("day"),
                                                start_time=dow.get("start_time"),
                                            )
                                            for dow in as_list(
                                                ssp_weekly.get("day_of_weeks")
                                            )
                                        ]
                                    )
                                    if ssp_weekly
                                    else None
                                ),
                            ),
                        )
                        if ssp_schedule
                        else cast(Any, None),
                        retention_policy=(
                            gcp.compute.ResourcePolicySnapshotSchedulePolicyRetentionPolicyArgs(
                                max_retention_days=int(
                                    ssp_ret.get("max_retention_days", 30)
                                ),
                                on_source_disk_delete=ssp_ret.get(
                                    "on_source_disk_delete"
                                ),
                            )
                            if ssp_ret
                            else None
                        ),
                        snapshot_properties=(
                            gcp.compute.ResourcePolicySnapshotSchedulePolicySnapshotPropertiesArgs(
                                chain_name=ssp_props.get("chain_name"),
                                guest_flush=ssp_props.get("guest_flush"),
                                labels=ssp_props.get("labels"),
                                storage_locations=cast(Any, final_storage_locations),
                            )
                            if ssp_props
                            else None
                        ),
                    )
                    if ssp
                    else None,
                    name=content.get("instance_schedule_name"),
                    project=GCP_PROJECT,
                    region=content.get("location", GCP_REGION),
                    opts=opts,
                )

                # policy = gcp.compute.ResourcePolicy(
                #     resource_name=f"compute_policy_{slugify(entry['file_name'])}_{i}",
                #     description=content.get("schedule_description"),
                #     # gcp.compute.ResourcePolicyDiskConsistencyGroupPolicyArgs()
                #     disk_consistency_group_policy=dcp,
                #     # gcp.compute.ResourcePolicyGroupPlacementPolicyArgs()
                #     group_placement_policy=gpp,
                #     # gcp.compute.ResourcePolicyInstanceSchedulePolicyArgs()
                #     instance_schedule_policy=isp,
                #     # gcp.compute.ResourcePolicySnapshotSchedulePolicyArgs()
                #     snapshot_schedule_policy=ssp,
                #     name=content.get("instance_schedule_name"),
                #     project=GCP_PROJECT,
                #     region=content.get("location", GCP_REGION),
                #     opts=opts,
                # )
                policies.append(policy)

            # 2.3) Attach the resource policy to the instance
            if content.get("attach_schedule") == 1:
                attachment = gcp.compute.DiskResourcePolicyAttachment(
                    resource_name=f"compute_attachment_{slugify(entry['file_name'])}_{i}",
                    disk=instance.name,
                    name=policy.name,
                    project=GCP_PROJECT,
                    zone=content.get("zone", f"{GCP_REGION}-b"),
                )
                attachments.append(attachment)

    return {"instances": instances, "policies": policies, "attachments": attachments}
