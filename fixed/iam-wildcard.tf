resource "aws_iam_policy" "wild_fixed" {
  name = "wild-fixed-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = ["ec2:Describe*"]
      Resource = "*"
    }]
  })
}
