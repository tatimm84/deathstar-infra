# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

variable "source_path" {
  description = "Source Path for JSON files"
  type        = string
}

variable "enviroment" {
  description = "Enviroment to replace"
  type        = string
}

variable "template_vars" {
  description = "Injection Vars in Template"
  type        = map(string)
  default     = {}
}

variable "files_regex" {
  description = "Regex Files to parse"
  type        = string
}

variable "is_json" {
  description = "Are files JSON?"
  type        = bool
  default     = true
}

variable "is_utf8" {
  description = "Are files UTF-8?"
  type        = bool
  default     = true
}

output "parsed_data" {
  description = "Dados JSON parseados e transformados."
  value = [
    for file in fileset(var.source_path, var.files_regex) : {
      source        = "${file}"
      full_name     = replace("${file}", "__env__", var.enviroment)
      path_name     = length(split("/", "${file}")) > 1 ? replace(split("/", "${file}")[0], "__env__", var.enviroment) : ""
      path_name_raw = length(split("/", "${file}")) > 1 ? split("/", "${file}")[0] : ""
      file_name     = split(".", replace(element(split("/", "${file}"), -1), "__env__", var.enviroment))[0]
      content       = var.is_json ? try(jsondecode(templatefile("${var.source_path}${file}", var.template_vars)), { "ERRO_NO_JSON" : "O arquivo '${file}' e invalido." }) : null
      content_raw   = var.is_json ? null : var.is_utf8 ? templatefile("${var.source_path}${file}", var.template_vars) : null
      sha1_json     = filesha1("${var.source_path}${file}")
  }]
}
