## AWS Databricks Terraform Consulting Template

This repository provisions a complete Databricks on AWS foundation using Terraform. It creates one or more Databricks workspaces (e.g., dev and prod), supporting AWS networking and IAM, a Unity Catalog metastore shared across workspaces, and per‑environment external storage plus catalogs.

### What gets created
- **AWS networking and IAM (per workspace)**: VPC, subnets, VPC endpoints, roles/policies, and supporting infrastructure required by Databricks (see `modules/workspace`).
- **Databricks workspaces**: One workspace per name you provide in `workspace_names` (see root `main.tf` → `module "aws-workspace-basic"`).
- **Unity Catalog metastore**: A single metastore in your region, assigned to all created workspaces (see `modules/metastore`).
- **External storage + Unity Catalog catalogs**: S3 bucket, IAM role and storage credential, external location, and a Databricks catalog for each environment (dev/prod) (see `modules/catalog`).

### Repository layout
- `providers.tf`: Declares and configures the AWS and Databricks providers, including provider aliases for specific workspaces.
- `main.tf`: Wires modules together: creates workspaces, creates/assigns the metastore, and sets up dev/prod catalogs. Includes a move block history for module address renames.
- `variables.tf`: Root input variables for the template (IDs, names, AWS profile/region, etc.).
- `terraform.tfvars` (local, ignored by git): Your real values for the variables.
- `terraform.example.tfvars`: Example/template values you can copy and adapt.
- `modules/workspace`: Provisions an AWS baseline plus a Databricks workspace. Contains networking (`vpc.tf`, `vpc_endpoints.tf`), IAM (`iam.tf`), S3 (`s3.tf`), and workspace resources (`workspace.tf`).
- `modules/metastore`: Provisions a Databricks Unity Catalog metastore and assigns it to all workspaces you created.
- `modules/catalog`: Provisions the S3 bucket and IAM role for external storage, creates a Databricks storage credential and external location, and finally creates a Databricks catalog backed by that location.

### How it works (high level)
1. Terraform uses your AWS profile/region to create networking, IAM, S3, and the Databricks workspaces.
2. A Unity Catalog metastore is created once and assigned to all workspaces.
3. For each environment (dev/prod), an S3 bucket + IAM role is created, a Databricks storage credential and external location are configured, and then a Databricks catalog is created backed by that location.
4. Provider aliases are used so that catalog resources are applied against the correct workspace URLs.

### Prerequisites
- Terraform CLI installed.
- An AWS account with credentials configured locally (via `~/.aws/credentials` profiles or your environment).
- A Databricks Account with a service principal and client credentials (client ID/secret) that have permissions to create workspaces and manage Unity Catalog objects at the account/workspace scopes.

### Configuration
Set the following inputs (see `variables.tf` for the authoritative list and descriptions):
- `databricks_account_id`: Your Databricks Account ID.
- `region`: AWS region for all resources (e.g., `us-west-2`).
- `aws_profile`: Name of your AWS CLI profile to use (must exist in `~/.aws/credentials`).
- `cidr_block`: VPC CIDR for the workspace networking.
- `client_id` / `client_secret`: Databricks service principal credentials used at account/workspace scope.
- `metastore_name`: Name of the Unity Catalog metastore.
- `workspace_names`: List of names for workspaces to create (e.g., `["my-dev", "my-prod"]`).
- `catalog_names`: List of catalog names. The template expects one ending with `-dev` and one ending with `-prod` so it can map them appropriately.
- `aws_account_id`: Your AWS account ID (used for IAM trust relationships).
- `tags` (optional): Map of tags to apply to supported AWS resources.

### Using terraform.example.tfvars
`terraform.example.tfvars` is a template that shows all of the required inputs. To use it:
1. Copy it to `terraform.tfvars` at the repository root:
   ```bash
   cp terraform.example.tfvars terraform.tfvars
   ```
2. Edit `terraform.tfvars` and fill in real values for your environment. Do not commit secrets.
3. `terraform.tfvars` is already in `.gitignore` to protect your sensitive values.

Tips:
- You can also keep multiple environment files such as `dev.tfvars` and `prod.tfvars` and pass them explicitly with `-var-file`.
- Where feasible, consider using environment variables (`TF_VAR_<name>`) for secrets, or a secrets manager. In this template, `client_secret` is read from variables; if you prefer, you can export an env var like `TF_VAR_client_secret` instead of placing it in a file.

### AWS and Databricks providers
- The AWS provider uses `region` and `aws_profile` variables (`providers.tf`). Ensure the profile exists in your local AWS config.
- The Databricks provider is configured twice for the accounts host and with aliases for specific workspace hosts. Note: the aliases in `providers.tf` reference keys like `"kevo-dev"` and `"kevo-prod"` from the workspace module outputs. If your `workspace_names` are different, update the alias host references accordingly or standardize on those names.

### Naming expectations for catalogs
In root `main.tf`, locals derive dev/prod catalog names by suffix:
- One name must end with `-dev` and one with `-prod` (e.g., `my-catalog-dev`, `my-catalog-prod`).
If the list does not contain such values, Terraform will fail to compute the mapping.

### Getting started
Initialize providers and modules:
```bash
terraform init
```

Create a plan (using the default `terraform.tfvars`):
```bash
terraform plan
```

Apply the changes:
```bash
terraform apply
```

Optionally, use separate var files per environment:
```bash
terraform plan -var-file=dev.tfvars
terraform apply -var-file=dev.tfvars
```

Destroy (be careful – deletes provisioned resources):
```bash
terraform destroy
```

### Troubleshooting
- **AWS profile not found**: Ensure `aws_profile` matches a named profile in `~/.aws/credentials` and that the profile has sufficient permissions.
- **Databricks 403/permissions**: Verify the service principal has the required account-level and workspace-level permissions to create workspaces, configure Unity Catalog, and manage storage credentials.
- **Catalog name mapping**: Ensure one catalog ends with `-dev` and one ends with `-prod` in `catalog_names`.
- **Provider alias host mismatch**: If you change workspace names from `kevo-dev`/`kevo-prod`, update `providers.tf` alias host references to point at the correct module outputs for your names.

### Security notes
- Do not commit `terraform.tfvars` or secrets. `.gitignore` already excludes it.
- Rotate and securely store your `client_secret`.
- Consider using a remote backend and a secrets manager in production.


