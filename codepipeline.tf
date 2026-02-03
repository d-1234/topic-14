# =============================================================================
# SECRET DETECTION PIPELINE - CODEPIPELINE CONFIGURATION
# =============================================================================
# This file defines the main CodePipeline that orchestrates secret detection
# =============================================================================

# Secure connection to GitHub (replaces deprecated OAuth tokens)
resource "aws_codestarconnections_connection" "github" {
  name          = "${var.project_name}-github"
  provider_type = "GitHub"
  
  tags = {
    Name        = "${var.project_name} GitHub Connection"
    Description = "Secure connection to GitHub repository"
  }
}

# KMS key for encrypting pipeline artifacts
resource "aws_kms_key" "pipeline_kms_key" {
  description             = "Encryption key for ${var.project_name} pipeline artifacts"
  deletion_window_in_days = 7
  
  # Allow root account and pipeline roles to use the key
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow Pipeline Services"
        Effect = "Allow"
        Principal = {
          AWS = [
            module.iam.codepipeline_role_arn,
            module.iam.codebuild_role_arn
          ]
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "*"
      }
    ]
  })
  
  tags = {
    Name        = "${var.project_name} Pipeline KMS Key"
    Description = "Encrypts CodePipeline artifacts"
  }
}

# KMS key alias for easier reference
resource "aws_kms_alias" "pipeline_kms_alias" {
  name          = "alias/${var.project_name}-pipeline"
  target_key_id = aws_kms_key.pipeline_kms_key.key_id
}

# Main CodePipeline - The heart of our secret detection system
resource "aws_codepipeline" "ml_secrets_pipeline" {
  name     = "${var.project_name}-pipeline"
  role_arn = module.iam.codepipeline_role_arn

  # Encrypted artifact storage
  artifact_store {
    location = module.storage.artifacts_bucket_name
    type     = "S3"
    
    encryption_key {
      id   = aws_kms_alias.pipeline_kms_alias.arn
      type = "KMS"
    }
  }

  # Stage 1: Source - Get code from GitHub
  stage {
    name = "Source"

    action {
      name             = "SourceAction"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn        = aws_codestarconnections_connection.github.arn
        FullRepositoryId     = "${var.github_owner}/${var.github_repo}"
        BranchName          = var.github_branch
        OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }

  # Stage 2: Security Scan - TruffleHog secret detection
  stage {
    name = "SecurityScan"

    action {
      name             = "TruffleHogSecretScan"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["scan_results"]
      version          = "1"

      configuration = {
        ProjectName = module.cicd.security_scan_project_name
      }
    }
  }

  # Stage 3: Results Analysis - Parse scan results and make decisions
  stage {
    name = "ResultsAnalysis"

    action {
      name             = "AnalyzeScanResults"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["scan_results"]
      output_artifacts = ["analysis_output"]
      version          = "1"

      configuration = {
        ProjectName = module.cicd.results_analysis_project_name
      }
    }
  }

  # Stage 4: Notification - Send alerts via CodeBuild
  stage {
    name = "Notification"

    action {
      name             = "SendNotification"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["analysis_output"]
      version          = "1"

      configuration = {
        ProjectName = module.cicd.notification_project_name
      }
    }
  }

  # Stage 5: Deployment Gate - Manual approval for deployment
  stage {
    name = "DeploymentGate"

    action {
      name     = "ApprovalGate"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"

      configuration = {
        NotificationArn = module.notifications.sns_topic_arn
        CustomData      = "Review security scan results before approving deployment."
      }
    }
  }
  
  tags = {
    Name        = "${var.project_name} Secret Detection Pipeline"
    Description = "5-stage automated secret detection and security scanning"
  }
}

# Get current AWS account ID for KMS policy
data "aws_caller_identity" "current" {}