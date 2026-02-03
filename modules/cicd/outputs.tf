output "security_scan_project_name" {
  description = "Name of the security scan CodeBuild project"
  value       = aws_codebuild_project.ml_security_scan.name
}

output "results_analysis_project_name" {
  description = "Name of the results analysis CodeBuild project"
  value       = aws_codebuild_project.results_analysis.name
}

output "notification_project_name" {
  description = "Name of the notification CodeBuild project"
  value       = aws_codebuild_project.notification.name
}