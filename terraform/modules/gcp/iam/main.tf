# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# IAM - SERVICE ACCOUNT CREATE
# --------------------------------------------------------------------
resource "google_service_account" "sa" {
  count                        = var.sa_create ? 1 : 0
  project                      = var.gcp_project
  account_id                   = var.service_account_id
  create_ignore_already_exists = var.create_ignore_already_exists
  display_name                 = var.display_name
  description                  = var.sa_description
  disabled                     = var.disabled
}

# --------------------------------------------------------------------
# IAM - PROJECT
# --------------------------------------------------------------------
resource "google_project_iam_member" "project_iam_member" {
  count   = var.iam_type == "project_iam_member" ? 1 : 0
  project = var.gcp_project
  role    = var.iam_role
  member  = var.iam_member

  dynamic "condition" {
    for_each = var.iam_condition
    content {
      title       = lookup(condition.value, "title")
      description = lookup(condition.value, "description", null)
      expression  = lookup(condition.value, "expression")
    }
  }
}

resource "google_project_iam_binding" "project_iam_binding" {
  count   = var.iam_type == "project_iam_binding" ? 1 : 0
  project = var.gcp_project
  role    = var.iam_role
  members = var.iam_members

  dynamic "condition" {
    for_each = var.iam_condition
    content {
      title       = lookup(condition.value, "title")
      description = lookup(condition.value, "description", null)
      expression  = lookup(condition.value, "expression")
    }
  }
}

data "google_iam_policy" "project_data_policy" {
  count = var.iam_type == "project_iam_policy" ? 1 : 0
  binding {
    role    = var.iam_role
    members = var.iam_members
    dynamic "condition" {
      for_each = var.iam_condition
      content {
        title       = lookup(condition.value, "title")
        description = lookup(condition.value, "description", null)
        expression  = lookup(condition.value, "expression")
      }
    }
  }
}
resource "google_project_iam_policy" "iam_policy" {
  count       = var.iam_type == "project_iam_policy" ? 1 : 0
  project     = var.gcp_project
  policy_data = data.google_iam_policy.project_data_policy[0].policy_data
}

resource "google_project_iam_audit_config" "project_iam_audit" {
  count   = var.iam_type == "project_iam_audit" ? 1 : 0
  project = var.gcp_project
  service = var.service

  dynamic "audit_log_config" {
    for_each = var.audit_log_config
    content {
      log_type         = lookup(audit_log_config.value, "log_type", null)
      exempted_members = lookup(audit_log_config.value, "exempted_members", null)
    }
  }
}

# --------------------------------------------------------------------
# IAM - SERVICE ACCOUNT
# --------------------------------------------------------------------
resource "google_service_account_iam_member" "sa_iam_member" {
  count              = var.iam_type == "service_iam_member" ? 1 : 0
  service_account_id = var.service_account_id
  role               = var.iam_role
  member             = var.iam_member

  dynamic "condition" {
    for_each = var.iam_condition
    content {
      title       = lookup(condition.value, "title")
      description = lookup(condition.value, "description", null)
      expression  = lookup(condition.value, "expression")
    }
  }
}

resource "google_service_account_iam_binding" "sa_iam_binding" {
  count              = var.iam_type == "service_iam_binding" ? 1 : 0
  service_account_id = var.service_account_id
  role               = var.iam_role
  members            = var.iam_members

  dynamic "condition" {
    for_each = var.iam_condition
    content {
      title       = lookup(condition.value, "title")
      description = lookup(condition.value, "description", null)
      expression  = lookup(condition.value, "expression")
    }
  }
}

data "google_iam_policy" "sa_data_policy" {
  count = var.iam_type == "service_iam_policy" ? 1 : 0
  binding {
    role    = var.iam_role
    members = var.iam_members
    dynamic "condition" {
      for_each = var.iam_condition
      content {
        title       = lookup(condition.value, "title")
        description = lookup(condition.value, "description", null)
        expression  = lookup(condition.value, "expression")
      }
    }
  }
}
resource "google_service_account_iam_policy" "iam_policy" {
  count              = var.iam_type == "service_iam_policy" ? 1 : 0
  service_account_id = var.service_account_id
  policy_data        = data.google_iam_policy.sa_data_policy[0].policy_data
}
