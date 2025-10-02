resource "aws_iam_role" "external_data_access" {
  name = "${var.catalog_bucket_name}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS =  "arn:aws:iam::414351767826:root"
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "sts:ExternalId": [var.databricks_account_id]
          }
        }
      }
    ]
  })
  tags = var.tags
}

resource "aws_iam_role_policy" "external_data_access" {
  name = "${var.catalog_bucket_name}-policy"
  role = aws_iam_role.external_data_access.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
           "s3:GetObject",
           "s3:PutObject",
           "s3:DeleteObject",
           "s3:ListBucket",
           "s3:GetBucketLocation",
           "s3:GetLifecycleConfiguration",
           "s3:PutLifecycleConfiguration"
        ],
        Resource = [
          "${aws_s3_bucket.databricks_external_storage.arn}/*", 
          "${aws_s3_bucket.databricks_external_storage.arn}"
        ],
        Effect = "Allow"
      },
      {
        Action = ["sts:AssumeRole"],
        Resource = [
          "arn:aws:iam::${var.aws_account_id}:role/${aws_iam_role.external_data_access.name}"
        ],
        Effect = "Allow"
      }
    ]
  }
)
} 

data "aws_iam_policy_document" "updated_trust_policy" { 
  depends_on = [aws_iam_role_policy.external_data_access]
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::414351767826:root"]
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.databricks_account_id]
    }
  }      
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.external_data_access.arn]
    }
  }
}

resource "time_sleep" "wait-update" {
  create_duration = "20s"
  depends_on = [
    data.aws_iam_policy_document.updated_trust_policy
  ]
}

resource "null_resource" "update_assume_role_policy" {
  depends_on = [time_sleep.wait-update]
  provisioner "local-exec" {
    command = "aws iam update-assume-role-policy --profile ${var.aws_profile} --role-name ${aws_iam_role.external_data_access.name} --policy-document '${data.aws_iam_policy_document.updated_trust_policy.json}'"
    }
}