resource "aws_kms_key" "secure_kms" {
  description         = "secure kms key"
  enable_key_rotation = true
}

