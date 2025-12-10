resource "aws_ebs_volume" "unencrypted" {
  availability_zone = "us-east-1a"
  size = 8
}
