# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# GCLOUD - CMD Instruction
# --------------------------------------------------------------------

# Trigger
resource "terraform_data" "trigger" {
  count      = var.cmd_instruction != null ? 1 : 0
  input      = join("-", [var.sha1_json])
  depends_on = []
}

resource "null_resource" "gcloud_cmd" {
  count = var.cmd_instruction != null ? 1 : 0
  provisioner "local-exec" {
    command = var.cmd_instruction
  }
  triggers   = { resource_id = terraform_data.trigger[0].input }
  depends_on = []
}
