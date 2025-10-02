module "aws-workspace-basic" {
  for_each              = toset(var.workspace_names)
  source                = "./modules/workspace"
  databricks_account_id = var.databricks_account_id
  region                = var.region
  tags                  = var.tags
  prefix                = each.value
  cidr_block            = var.cidr_block
}

module "metastore" {
  source                = "./modules/metastore"
  metastore_name        = var.metastore_name
  region                = var.region
  workspace_ids         = [for k, v in module.aws-workspace-basic : v.workspace_id]
}

locals {
  dev_catalog_name  = one([for n in var.catalog_names : n if can(regex(".*-dev$", n))])
  prod_catalog_name = one([for n in var.catalog_names : n if can(regex(".*-prod$", n))])
}

module "catalog_dev" {
  source                = "./modules/catalog"
  databricks_account_id = var.databricks_account_id
  catalog_name          = local.dev_catalog_name
  catalog_bucket_name   = local.dev_catalog_name
  workspace_url         = [for k, v in module.aws-workspace-basic : v.databricks_host]
  aws_account_id        = var.aws_account_id
  aws_profile           = var.aws_profile
  region                = var.region
  providers             = {
    databricks = databricks.dev-mws
  }
  depends_on = [
    module.metastore
  ]
}

module "catalog_prod" {
  source                = "./modules/catalog"
  databricks_account_id = var.databricks_account_id
  catalog_name          = local.prod_catalog_name
  catalog_bucket_name   = local.prod_catalog_name
  workspace_url         = [for k, v in module.aws-workspace-basic : v.databricks_host]
  aws_account_id        = var.aws_account_id
  aws_profile           = var.aws_profile
  region                = var.region
  providers             = {
    databricks = databricks.prod-mws
  }
  depends_on = [
    module.metastore
  ]
}

moved {
  from = module.catalog["kevo-catalog-dev"]
  to   = module.catalog_dev
}

moved {
  from = module.catalog["kevo-catalog-prod"]
  to   = module.catalog_prod
}