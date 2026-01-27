# S3 bucket for application artifacts
resource "aws_s3_bucket" "app_artifacts" {
  bucket = "${var.project_name}-artifacts-${random_id.bucket_suffix.hex}"
}

resource "aws_s3_bucket_versioning" "app_artifacts_versioning" {
  bucket = aws_s3_bucket.app_artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 bucket for source code
resource "aws_s3_bucket" "app_source_code" {
  bucket = "${var.project_name}-source-${random_id.bucket_suffix.hex}"
}

resource "aws_s3_bucket_versioning" "app_source_code_versioning" {
  bucket = aws_s3_bucket.app_source_code.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}