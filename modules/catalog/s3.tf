# Create an S3 Bucket for Databricks Storage
resource "aws_s3_bucket" "databricks_external_storage" {
  bucket = "${var.catalog_bucket_name}"  # Make the name unique
  force_destroy = true
  tags = {
    Name        = "${var.catalog_bucket_name}"
  }
}

# Enable S3 Versioning (Optional, Recommended for Data Protection)
resource "aws_s3_bucket_versioning" "databricks_root_versioning" {
  bucket = aws_s3_bucket.databricks_external_storage.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Block Public Access to the S3 Bucket
resource "aws_s3_bucket_public_access_block" "databricks_root" {
  bucket = aws_s3_bucket.databricks_external_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "databricks_external_bucket_policy" {
  bucket = aws_s3_bucket.databricks_external_storage.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid      = "AllowDatabricksRoleAccess",
        Effect   = "Allow",
        Principal = {
          AWS = aws_iam_role.external_data_access.arn
        },
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ],
        Resource = [
          aws_s3_bucket.databricks_external_storage.arn,
          "${aws_s3_bucket.databricks_external_storage.arn}/*"
        ]
      }
    ]
  })
}

