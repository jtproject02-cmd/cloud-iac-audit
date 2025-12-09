resource "aws_s3_bucket" "bad_bucket" {
  bucket = "public-bucket-example"
  acl    = "public-read"
}
