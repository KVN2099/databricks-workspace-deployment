resource "databricks_metastore" "this" {
  name          = var.metastore_name
  region        = var.region
  force_destroy = true
}

resource "databricks_metastore_assignment" "this" {
  metastore_id = databricks_metastore.this.id
  count       = length(var.workspace_ids)
  workspace_id = var.workspace_ids[count.index]
}