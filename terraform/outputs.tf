# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# OUTPUTS
# --------------------------------------------------------------------
output "src_infra_path" {
  sensitive = false
  value     = var.SRC_INFRA_PATH
}
output "abs_path_module" {
  sensitive = false
  value     = abspath(path.module)
}
output "abs_path_root" {
  sensitive = false
  value     = abspath(path.root)
}
output "abs_path_cwd" {
  sensitive = false
  value     = abspath(path.cwd)
}

output "fileset_src" {
  sensitive = false
  value     = fileset("${var.SRC_INFRA_PATH}", "**")
}
output "fileset_root" {
  sensitive = false
  value     = fileset("${abspath(path.root)}", "**")
}

output "google_client_config" {
  sensitive = true
  value     = data.google_client_config.default.access_token
}
