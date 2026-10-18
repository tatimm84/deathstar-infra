# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

"""
GCP SSL Security component.
Converted from terraform/gcp_ssl_security.tf and modules/gcp/ssl_security
"""

from __future__ import annotations

from typing import Any, cast

import pulumi_gcp as gcp
from utils.json_reader import read_json_files
from variables import GCP_PROJECT, GCP_REGION, SRC_INFRA_PATH

import pulumi


def create_ssl_security(
    template_vars: dict[str, str],
    opts: pulumi.ResourceOptions | None = None,
    json_files: list[dict[str, Any]] | None = None,
) -> dict[str, Any]:
    """
    Create SSL Security resources based on JSON configuration files.
    Files should be at root: infra/gcp/auto/ssl_security/<any>.json

    Args:
        template_vars: Template variables for substitution
        opts: Pulumi resource options (opcional)
        json_files: (opcional) Loaded JSON files list for local tests.
            If None, use read_json_files(...) from SRC_INFRA_PATH.

    Returns:
        Dictionary with created SSL Security resources
    """
    # 1) Read JSONs (with variable substitution)
    if json_files is None:
        files = read_json_files(
            source_path=f"{SRC_INFRA_PATH}/gcp/auto/ssl_security/",
            files_regex="**",
            template_vars=template_vars,
        )
    else:
        files = json_files

    # 2) Validate files and create resources
    certificates: list[Any] = []
    policies: list[Any] = []
    armor_policies: list[Any] = []
    for entry in files:
        content = entry.get("content", {})

        # Create SSL Certificate
        cert = _create_certificate(entry, content, opts)
        if cert:
            certificates.append(cert)

        # Create SSL Policy
        policy = _create_ssl_policy(entry, content, opts)
        if policy:
            policies.append(policy)

        # Create Cloud Armor Security Policy
        armor = _create_armor_policy(entry, content, opts)
        if armor:
            armor_policies.append(armor)

    return {
        "certificates": certificates,
        "policies": policies,
        "armor_policies": armor_policies,
    }


def _create_certificate(
    entry: dict, content: dict, opts: pulumi.ResourceOptions | None
) -> Any:
    """Helper to create SSL certificate resource."""
    if not content.get("ssl_certificate"):
        return None

    # Read certificate and private key files
    certificate_data = None
    private_key_data = None

    if content.get("certificate"):
        try:
            with open(content["certificate"]) as f:
                certificate_data = f.read().replace("\\n", "\n")
        except Exception as e:
            pulumi.log.warn(f"Could not read certificate file: {e}")

    if content.get("private_key"):
        try:
            with open(content["private_key"]) as f:
                private_key_data = f.read().replace("\\n", "\n")
        except Exception as e:
            pulumi.log.warn(f"Could not read private key file: {e}")

    if not (certificate_data and private_key_data):
        return None

    cert_type = content.get("ssl_certificate_type", "global")
    if cert_type == "regional":
        return gcp.compute.RegionSslCertificate(
            f"ssl_cert_regional_{entry['source']}",
            name=content["ssl_certificate"],
            certificate=certificate_data,
            private_key=private_key_data,
            region=content.get("region", GCP_REGION),
            project=GCP_PROJECT,
            description=content.get("ssl_certificate_description"),
            opts=opts,
        )

    return gcp.compute.SSLCertificate(
        f"ssl_cert_{entry['source']}",
        name=content["ssl_certificate"],
        certificate=certificate_data,
        private_key=private_key_data,
        project=GCP_PROJECT,
        description=content.get("ssl_certificate_description"),
        name_prefix=content.get("name_prefix"),
        opts=opts,
    )


def _create_ssl_policy(
    entry: dict, content: dict, opts: pulumi.ResourceOptions | None
) -> Any:
    """Helper to create SSL policy resource."""
    if not content.get("ssl_policy"):
        return None

    policy_type = content.get("ssl_policy_type", "global")
    if policy_type == "regional":
        return gcp.compute.RegionSslPolicy(
            f"ssl_policy_regional_{entry['source']}",
            name=content["ssl_policy"],
            region=content.get("region", GCP_REGION),
            project=GCP_PROJECT,
            profile=content.get("profile"),
            min_tls_version=content.get("min_tls_version"),
            custom_features=content.get("custom_features"),
            opts=opts,
        )

    return gcp.compute.SSLPolicy(
        f"ssl_policy_{entry['source']}",
        name=content["ssl_policy"],
        project=GCP_PROJECT,
        profile=content.get("profile"),
        min_tls_version=content.get("min_tls_version"),
        custom_features=content.get("custom_features"),
        opts=opts,
    )


def _create_armor_policy(
    entry: dict, content: dict, opts: pulumi.ResourceOptions | None
) -> Any:
    """Helper to create Cloud Armor security policy."""
    if not content.get("armor"):
        return None

    rules = []
    if content.get("rule"):
        for rule_config in content["rule"]:
            rule = gcp.compute.SecurityPolicyRuleArgs(
                action=rule_config.get("action"),
                priority=rule_config.get("priority"),
                description=rule_config.get("description"),
                preview=rule_config.get("preview"),
                match=cast(
                    Any,
                    gcp.compute.SecurityPolicyRuleMatchArgs(
                        versioned_expr=rule_config.get("match", {}).get(
                            "versioned_expr"
                        ),
                        config=gcp.compute.SecurityPolicyRuleMatchConfigArgs(
                            src_ip_ranges=rule_config.get("match", {})
                            .get("config", {})
                            .get("src_ip_ranges"),
                        )
                        if rule_config.get("match", {}).get("config")
                        else None,
                        expr=gcp.compute.SecurityPolicyRuleMatchExprArgs(
                            expression=rule_config.get("match", {})
                            .get("expr", {})
                            .get("expression"),
                        )
                        if rule_config.get("match", {}).get("expr")
                        else None,
                    )
                    if rule_config.get("match")
                    else None,
                ),
            )
            rules.append(rule)

    return gcp.compute.SecurityPolicy(
        f"armor_{entry['source']}",
        name=content["armor"],
        project=GCP_PROJECT,
        description=content.get("armor_description"),
        type=content.get("type"),
        advanced_options_config=gcp.compute.SecurityPolicyAdvancedOptionsConfigArgs(
            **content["advanced_options_config"]
        )
        if content.get("advanced_options_config")
        else None,
        adaptive_protection_config=gcp.compute.SecurityPolicyAdaptiveProtectionConfigArgs(
            **content["adaptive_protection_config"]
        )
        if content.get("adaptive_protection_config")
        else None,
        recaptcha_options_config=gcp.compute.SecurityPolicyRecaptchaOptionsConfigArgs(
            **content["recaptcha_options_config"]
        )
        if content.get("recaptcha_options_config")
        else None,
        rules=rules if rules else None,
        opts=opts,
    )
