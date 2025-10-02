# versions.tf
terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = ">=1.13.0"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
  profile = var.aws_profile
}

provider "databricks" {
  host       = "https://accounts.cloud.databricks.com"
  account_id = var.databricks_account_id
  client_id     = var.client_id
  client_secret = var.client_secret
}

provider "databricks" {
  alias      = "acc"
  host       = "https://accounts.cloud.databricks.com"
  account_id = var.databricks_account_id
  client_id     = var.client_id
  client_secret = var.client_secret
}

provider "databricks" {
  alias      = "dev-mws"
  host       = module.aws-workspace-basic["kevo-dev"].databricks_host
  account_id = var.databricks_account_id
  client_id     = var.client_id
  client_secret = var.client_secret
}

provider "databricks" {
  alias      = "prod-mws"
  host       = module.aws-workspace-basic["kevo-prod"].databricks_host
  account_id = var.databricks_account_id
  client_id     = var.client_id
  client_secret = var.client_secret
}