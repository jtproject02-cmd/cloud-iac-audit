resource "aws_iam_policy" "secure_policy" {
  name = "secure-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeVolumes"
        ]
        Resource = "*"
      }
    ]
  })
}

