# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

# --------------------------------------------------------------------
# DATAFLOW - JOB
# --------------------------------------------------------------------
resource "google_dataflow_job" "job" {
  count                        = var.name != null ? 1 : 0
  project                      = var.gcp_project
  region                       = var.gcp_region
  zone                         = var.gcp_zone
  name                         = var.name
  template_gcs_path            = var.template_gcs_path
  temp_gcs_location            = var.temp_gcs_region
  parameters                   = var.parameters
  labels                       = var.labels
  transform_name_mapping       = var.transform_name_mapping
  max_workers                  = var.max_workers
  on_delete                    = var.on_delete
  skip_wait_on_job_termination = var.skip_wait_on_job_termination
  service_account_email        = var.service_account_email
  network                      = var.network
  subnetwork                   = var.subnetwork
  machine_type                 = var.machine_type
  kms_key_name                 = var.kms_key_name
  ip_configuration             = var.ip_configuration
  additional_experiments       = var.additional_experiments
  enable_streaming_engine      = var.enable_streaming_engine
}
