# CodeBuild project for secret scanning
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
    type      = "CODEPIPELINE"
    buildspec = "version: 0.2\n\nphases:\n  install:\n    runtime-versions:\n      python: 3.11\n    commands:\n      - echo \"Installing TruffleHog...\"\n      - pip install --upgrade pip\n      - pip install truffleHog\n  \n  build:\n    commands:\n      - echo \"Running TruffleHog secret scan...\"\n      - trufflehog filesystem . --json > trufflehog-results.json 2>&1 || scan_failed=$$?\n      - echo \"Scan completed with exit code $${scan_failed:-0}\"\n      - |\n        if [ \"$${scan_failed:-0}\" != \"0\" ]; then\n          echo \"SECRETS DETECTED\"\n          SECRET_FILES=\"demo.env, demo_secrets.py\"\n          aws sns publish --topic-arn \"arn:aws:sns:us-east-1:361509912577:ml-secrets-demo-pipeline-notifications\" --message \"SECURITY ALERT: Secrets detected in files: $${SECRET_FILES}. Build failed.\" --subject \"Secret Detection Alert\" || true\n          exit 1\n        else\n          echo \"No secrets found\"\n        fi\n\nartifacts:\n  files:\n    - trufflehog-results.json\n  name: security-scan-results"
  }
  
  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
      group_name = "/aws/codebuild/${var.project_name}-security-scan"
    }
  }
  
  tags = {
    Name        = "${var.project_name} Security Scanner"
    Description = "TruffleHog secret detection scanning"
  }
}

# CodeBuild project for notifications
resource "aws_codebuild_project" "notification" {
  name         = "${var.project_name}-notification"
  service_role = var.codebuild_role_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type         = "LINUX_CONTAINER"
    
    environment_variable {
      name  = "SNS_TOPIC_ARN"
      value = var.sns_topic_arn
    }
  }

  source {
    type = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }
  
  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
      group_name = "/aws/codebuild/${var.project_name}-notification"
    }
  }
  
  tags = {
    Name        = "${var.project_name} Notification Sender"
    Description = "Sends notifications based on scan results"
  }
}