# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

"""
Component templates for remaining GCP services.
These are simplified templates that follow the same pattern as the implemented
components.
Each can be expanded based on specific requirements.
"""

# The following components follow the same pattern:
# 1) Read JSON configuration files (with variable substitution)
#    from SRC_INFRA_PATH/gcp/auto/{service_name}/
# 2) Pre-process if needed
# 3) Validate files and create resources using pulumi_gcp

# Template structure for each component:
#
# def create_{resource_name}(
#     template_vars: dict[str, str],
#     opts: pulumi.ResourceOptions | None = None,
#     json_files: list[dict[str, Any]] | None = None,
# ) -> dict[str, Any]:
#     # 1) Read JSONs (with variable substitution)
#     if json_files is None:
#         files = read_json_files(
#             source_path=f"{SRC_INFRA_PATH}/gcp/auto/{resource}/",
#             files_regex="**",
#             template_vars=template_vars,
#         )
#     else:
#         files = json_files
#
#     # 2) Pre-process files (if needed)
#     processed_files = _preprocess(files, template_vars)
#
#     # 3) Validate files and create resources
#     resources: list[Any] = []
#     for entry in files:
#         content = entry.get("content", {}) or {}
#
#         # 3.1) Validate files
#         validate_entries(entries=[entry], schema=gcp_workflows)
#
#         # 3.2) Create resources
#         resource = gcp.{resource_name}.{resource_type}(
#             f"{service}_{entry['source']}",
#             # ... resource configuration from content
#             opts=opts,
#         )
#         resources.append(resource)
#
#     return {"resources": resources}
