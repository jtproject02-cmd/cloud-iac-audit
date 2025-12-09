resource "aws_s3_bucket" "good_bucket" {
  bucket = "private-bucket-example"
  acl    = "private"
}
