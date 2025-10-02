variable "databricks_account_id" {
  type        = string
  description = "Databricks Account ID"
}

variable "tags" {
  default     = {}
  type        = map(string)
  description = "Optional tags to add to created resources"
}

variable "cidr_block" {
  description = "IP range for AWS VPC"
  type        = string
  default     = "10.4.0.0/16"
}

variable "region" {
  default     = "eu-west-1"
  type        = string
  description = "AWS region to deploy to"
}

variable "prefix" {
  default     = ""
  type        = string
  description = "Prefix for use in the generated names"
}

variable "client_id" {
  type        = string
  description = "Databricks Client ID"
}

variable "client_secret" {
  type        = string
  description = "Databricks Client Secret"
}

variable "aws_profile" {
  type        = string
  description = "AWS Profile"
}

variable "metastore_name" {
  type        = string
  description = "Metastore Name"
}

variable "workspace_names" {
  type        = list(string)
  description = "Workspace Names"
}

variable "catalog_names" {
  type        = list(string)
  description = "Catalog Name"
}

variable "aws_account_id" {
  type        = string
  description = "AWS Account ID"
}