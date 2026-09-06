
resource "aws_s3_bucket" "s3_backend" {
  bucket = var.tfstate_bucket_name

  #checkov:skip=CKV_AWS_144:Personal portfolio project; state bucket doesn't require cross-region replication
  #checkov:skip=CKV2_AWS_62:No downstream consumer (Lambda/SNS) needs bucket event notifications for this project for now
  #checkov:skip=CKV_AWS_18:Access logging requires a second bucket + IAM scope expansion; not justified for a personal Terraform state bucket at this stage
  #checkov:skip=CKV_AWS_145:SSE-S3 is intentionally used instead of SSE-KMS; a customer-managed KMS key adds IAM and operational complexity not justified for this personal project
}

resource "aws_s3_bucket_versioning" "s3_backend_versioning" {
  bucket = aws_s3_bucket.s3_backend.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "s3_backend_s3_public_access_block" {
  bucket = aws_s3_bucket.s3_backend.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_backend_s3_aes256" {
  bucket = aws_s3_bucket.s3_backend.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "s3_backend_lifecycle" {
  bucket = aws_s3_bucket.s3_backend.id

  rule {
    id     = "expire-old-noncurrent-versions"
    status = "Enabled"

    filter {}
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}



