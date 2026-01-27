output "secret_arn" {
  description = "ARN of the Secrets Manager secret"
  value       = aws_secretsmanager_secret.ml_api_key.arn
}

output "parameter_arn" {
  description = "ARN of the SSM parameter"
  value       = aws_ssm_parameter.ml_config.arn
}

output "parameter_name" {
  description = "Name of the SSM parameter"
  value       = aws_ssm_parameter.ml_config.name
}