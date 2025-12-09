resource "aws_kms_key" "rotate" {
  description          = "good kms key"
  enable_key_rotation  = true
}
