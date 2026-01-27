output "ml_execution_role_arn" {
  description = "ARN of the ML execution role"
  value       = aws_iam_role.ml_execution_role.arn
}

output "codebuild_role_arn" {
  description = "ARN of the CodeBuild role"
  value       = aws_iam_role.codebuild_role.arn
}

output "codepipeline_role_arn" {
  description = "ARN of the CodePipeline role"
  value       = aws_iam_role.codepipeline_role.arn
}