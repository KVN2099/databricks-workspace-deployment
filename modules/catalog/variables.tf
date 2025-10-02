variable "databricks_account_id" {
  default = ""
}

variable "tags" {
  default = {}
}

variable "region" {
  default = ""
  type    = string
}

variable "aws_profile" {
  type    = string
}


variable "catalog_bucket_name" {
  type    = string
}

variable "catalog_name" {
  type    = string  
}

variable "workspace_url" {
  type    = list(string)
}

variable "aws_account_id" {
  type    = string
  
}