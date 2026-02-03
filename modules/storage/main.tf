# S3 bucket for application artifacts
resource "aws_s3_bucket" "app_artifacts" {
  bucket        = "${var.project_name}-artifacts-${random_id.bucket_suffix.hex}"
  force_destroy = true
  
  tags = {
    Project     = var.project_name
    Environment = "production"
    Purpose     = "codepipeline-artifacts"
  }
}

resource "aws_s3_bucket_versioning" "app_artifacts_versioning" {
  bucket = aws_s3_bucket.app_artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "app_artifacts_encryption" {
  bucket = aws_s3_bucket.app_artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "app_artifacts_pab" {
  bucket = aws_s3_bucket.app_artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 bucket for source code
resource "aws_s3_bucket" "app_source_code" {
  bucket        = "${var.project_name}-source-${random_id.bucket_suffix.hex}"
  force_destroy = true
  
  tags = {
    Project     = var.project_name
    Environment = "production"
    Purpose     = "source-code-storage"
  }
}

resource "aws_s3_bucket_versioning" "app_source_code_versioning" {
  bucket = aws_s3_bucket.app_source_code.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "app_source_code_encryption" {
  bucket = aws_s3_bucket.app_source_code.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "app_source_code_pab" {
  bucket = aws_s3_bucket.app_source_code.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}