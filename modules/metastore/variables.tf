variable "metastore_name" {
  type        = string
  description = "Metastore Name"
}

variable "region" {
  type        = string
  description = "Region"
}

variable "workspace_ids" {
  type        = list(string)
  description = "Workspace IDs"
}