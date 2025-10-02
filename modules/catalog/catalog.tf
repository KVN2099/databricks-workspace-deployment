resource "databricks_storage_credential" "external" {
  name = aws_iam_role.external_data_access.name
  provider = databricks
  aws_iam_role {
    role_arn = aws_iam_role.external_data_access.arn
  }
  comment = "Managed by TF"
  depends_on = [
    null_resource.update_assume_role_policy
  ]
}

resource "time_sleep" "wait-credential" {
  create_duration = "20s"
  depends_on = [
    databricks_storage_credential.external
  ]
}

resource "databricks_external_location" "some" {
  name            = aws_iam_role.external_data_access.name
  url             = "s3://${aws_s3_bucket.databricks_external_storage.id}"
  credential_name = databricks_storage_credential.external.name
  comment         = "Managed by TF"
  depends_on = [
    time_sleep.wait-credential
  ]
}

resource "databricks_catalog" "sandbox" {
  name    = var.catalog_name
  comment = "this catalog is managed by terraform"
  isolation_mode = "OPEN"
  storage_root = databricks_external_location.some.url
  depends_on = [
    aws_s3_bucket.databricks_external_storage
  ]
}