resource "aws_kms_key" "no_rotate" {
  description          = "bad kms key"
  enable_key_rotation  = false
}
