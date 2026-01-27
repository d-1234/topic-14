output "security_scan_project_name" {
  description = "Name of the security scan CodeBuild project"
  value       = aws_codebuild_project.ml_security_scan.name
}