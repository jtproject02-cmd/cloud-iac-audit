resource "aws_kms_key" "no_rotate" {
  enable_key_rotation = false
}

