output "ml_role_arn" {
  description = "ARN of the ML execution role"
  value       = module.iam.ml_execution_role_arn
}

output "secret_arn" {
  description = "ARN of the Secrets Manager secret"
  value       = module.secrets.secret_arn
}

output "parameter_name" {
  description = "Name of the SSM parameter"
  value       = module.secrets.parameter_name
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket for application artifacts"
  value       = module.storage.artifacts_bucket_name
}

output "s3_source_bucket_name" {
  description = "Name of the S3 bucket for source code"
  value       = module.storage.source_bucket_name
}

output "codepipeline_name" {
  description = "Name of the CodePipeline"
  value       = aws_codepipeline.ml_secrets_pipeline.name
}

output "codebuild_project_name" {
  description = "Name of the security scan CodeBuild project"
  value       = module.cicd.security_scan_project_name
}