# Secrets Manager secret for API keys
resource "aws_secretsmanager_secret" "ml_api_key" {
  name        = "${var.project_name}/api-key-v2"
  description = "API key for ML service"
}

resource "aws_secretsmanager_secret_version" "ml_api_key_version" {
  secret_id = aws_secretsmanager_secret.ml_api_key.id
  secret_string = jsonencode({
    api_key = "demo-api-key-value"
    endpoint = "https://api.example.com"
  })
}

# Systems Manager Parameter Store for configuration
resource "aws_ssm_parameter" "ml_config" {
  name  = "/${var.project_name}/config"
  type  = "String"
  value = jsonencode({
    model_name = "demo-model"
    batch_size = 32
    max_epochs = 10
  })
}