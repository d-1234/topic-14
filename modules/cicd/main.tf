# CodeBuild project for secret scanning only
resource "aws_codebuild_project" "ml_security_scan" {
  name         = "${var.project_name}-security-scan"
  service_role = var.codebuild_role_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type         = "LINUX_CONTAINER"
    
    environment_variable {
      name  = "PROJECT_NAME"
      value = var.project_name
    }
  }

  source {
    type = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }
  
  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
      group_name = "/aws/codebuild/${var.project_name}-security-scan"
    }
  }
  
  tags = {
    Project     = var.project_name
    Environment = "production"
    Purpose     = "security-scanning"
  }
}