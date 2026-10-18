# SPDX-FileCopyrightText: 2025 Suzano S.A.
#
# SPDX-License-Identifier: MIT

terraform {
  required_version = ">= 1.0.0"
  backend "gcs" {}
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.44.2"
    }
    sonarcloud = {
      source  = "rewe-digital/sonarcloud"
      version = "~> 0.5.2"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.2"
    }
  }
}

provider "google" {
  project = var.GCP_PROJECT
  region  = var.GCP_REGION
}
data "google_client_config" "default" {}
provider "sonarcloud" {
  organization = "suzano"
  token        = var.SONARCLOUD_TOKEN
}
provider "docker" {
  registry_auth {
    address  = "${var.GCP_REGION}-docker.pkg.dev"
    username = "oauth2accesstoken"
    password = data.google_client_config.default.access_token
  }
}
