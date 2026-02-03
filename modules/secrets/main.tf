# Secrets Manager secret for API keys
resource "aws_secretsmanager_secret" "ml_api_key" {
  name                    = "${var.project_name}/api-key-v3"
  description             = "API key for ML service"
  recovery_window_in_days = 7
  
  tags = {
    Project     = var.project_name
    Environment = "production"
    Purpose     = "ml-api-credentials"
  }
}

resource "aws_secretsmanager_secret_version" "ml_api_key_version" {
  secret_id = aws_secretsmanager_secret.ml_api_key.id
  secret_string = jsonencode({
    api_key = "PLACEHOLDER_API_KEY_REPLACE_AFTER_DEPLOYMENT"
    endpoint = "https://api.example.com"
  })
  
  lifecycle {
    ignore_changes = [secret_string]
  }
}

# Systems Manager Parameter Store for configuration
resource "aws_ssm_parameter" "ml_config" {
  name  = "/${var.project_name}/config"
  type  = "SecureString"
  value = jsonencode({
    model_name = "demo-model"
    batch_size = 32
    max_epochs = 10
  })
  
  tags = {
    Project     = var.project_name
    Environment = "production"
    Purpose     = "ml-configuration"
  }
}