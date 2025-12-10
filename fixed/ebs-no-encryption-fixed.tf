# KMS key for EBS encryption
resource "aws_kms_key" "ebs_kms" {
  description         = "CMK for EBS volume encryption"
  enable_key_rotation = true

  # Minimal, non-wildcard principal policy
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "EnableRootPermissions"
        Effect   = "Allow"
        Principal = {
          AWS = "arn:aws:iam::123456789012:root"
        }
        Action   = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })
}

# Secure, KMS-encrypted EBS volume
resource "aws_ebs_volume" "secure_volume" {
  availability_zone = "us-east-1a"
  size              = 8
  encrypted         = true
  kms_key_id        = aws_kms_key.ebs_kms.arn

  tags = {
    Name = "secure-ebs-volume"
  }
}
