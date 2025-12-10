# Least-privilege IAM policy: read-only access to a specific S3 bucket
resource "aws_iam_policy" "limited_read_only" {
  name        = "limited-readonly-policy"
  description = "Read-only access to a single logs bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowListBucket"
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = "arn:aws:s3:::app-logs-bucket"
      },
      {
        Sid    = "AllowGetObjects"
        Effect = "Allow"
        Action = [
          "s3:GetObject"
        ]
        Resource = "arn:aws:s3:::app-logs-bucket/*"
      }
    ]
  })
}
