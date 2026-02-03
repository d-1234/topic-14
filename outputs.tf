# =============================================================================
# SECRET DETECTION PIPELINE - OUTPUT VALUES
# =============================================================================
# These outputs provide important information about the deployed resources
# =============================================================================

output "pipeline_name" {
  description = "Name of the CodePipeline for secret detection"
  value       = aws_codepipeline.ml_secrets_pipeline.name
}

output "pipeline_arn" {
  description = "ARN of the CodePipeline"
  value       = aws_codepipeline.ml_secrets_pipeline.arn
}

output "github_connection_arn" {
  description = "ARN of the CodeStar connection to GitHub"
  value       = aws_codestarconnections_connection.github.arn
}

output "artifacts_bucket" {
  description = "S3 bucket storing pipeline artifacts"
  value       = module.storage.artifacts_bucket_name
}

output "notification_topic" {
  description = "SNS topic for security alerts"
  value       = module.notifications.sns_topic_arn
}

output "secrets_manager_arn" {
  description = "ARN of the Secrets Manager secret"
  value       = module.secrets.secret_arn
  sensitive   = true
}

output "codebuild_project" {
  description = "Name of the CodeBuild project for secret scanning"
  value       = module.cicd.security_scan_project_name
}

output "deployment_summary" {
  description = "Summary of the deployed secret detection pipeline"
  value = {
    project_name       = var.project_name
    aws_region        = var.aws_region
    github_repo       = "${var.github_owner}/${var.github_repo}"
    monitored_branch  = var.github_branch
    notification_email = var.notification_email
    pipeline_url      = "https://console.aws.amazon.com/codesuite/codepipeline/pipelines/${aws_codepipeline.ml_secrets_pipeline.name}/view"
  }
}