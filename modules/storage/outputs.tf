output "artifacts_bucket_name" {
  description = "Name of the S3 bucket for application artifacts"
  value       = aws_s3_bucket.app_artifacts.bucket
}

output "source_bucket_name" {
  description = "Name of the S3 bucket for source code"
  value       = aws_s3_bucket.app_source_code.bucket
}