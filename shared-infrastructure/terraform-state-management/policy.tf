# Cross-account bucket policy to access terraform state
resource "aws_s3_bucket_policy" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowManagementAccountAccess"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::133954050615:root"
        }
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          aws_s3_bucket.terraform_state.arn,
          "${aws_s3_bucket.terraform_state.arn}/*"
        ]
      },
      {
        Sid    = "AllowProductionAccountListBucket"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::454138417948:root"
        }
        Action   = "s3:ListBucket"
        Resource = aws_s3_bucket.terraform_state.arn
        Condition = {
          StringLike = {
            "s3:prefix" = "production/*"
          }
        }
      },
      {
        Sid    = "AllowProductionReadBackendBucketMetadata"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::454138417948:root"
        }
        Action = [
          "s3:GetBucketLocation",
          "s3:GetBucketVersioning",
          "s3:GetEncryptionConfiguration",
          "s3:GetBucketPublicAccessBlock",
          "s3:GetBucketPolicy"
        ]
        Resource = aws_s3_bucket.terraform_state.arn
      },
      {
        Sid    = "AllowProductionAccountObjectAccess"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::454138417948:root"
        }
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "${aws_s3_bucket.terraform_state.arn}/production/*"
      }
    ]
  })
}
