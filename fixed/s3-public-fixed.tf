# Secure S3 bucket (not public, encrypted, versioned, logged)
resource "aws_s3_bucket" "secure_bucket" {
  bucket = "secure-bucket-example-435"
}

# Block public access
resource "aws_s3_bucket_public_access_block" "secure_bucket_block" {
  bucket                  = aws_s3_bucket.secure_bucket.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

# Default encryption with KMS
resource "aws_s3_bucket_server_side_encryption_configuration" "secure_bucket_sse" {
  bucket = aws_s3_bucket.secure_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.secure_kms.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# Versioning
resource "aws_s3_bucket_versioning" "secure_bucket_versioning" {
  bucket = aws_s3_bucket.secure_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Access logging (logs to a separate bucket, usually)
resource "aws_s3_bucket" "logs_bucket" {
  bucket = "secure-bucket-logs-435"
}

resource "aws_s3_bucket_logging" "secure_bucket_logging" {
  bucket        = aws_s3_bucket.secure_bucket.id
  target_bucket = aws_s3_bucket.logs_bucket.id
  target_prefix = "logs/"
}

# Lifecycle configuration example (helps with some lifecycle-related checks)
resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  bucket = aws_s3_bucket.secure_bucket.id

  rule {
    id     = "abort-multipart-uploads"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}
