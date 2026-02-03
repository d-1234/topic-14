# =============================================================================
# SECRET DETECTION PIPELINE - MAIN CONFIGURATION
# =============================================================================
# This file orchestrates a comprehensive secret detection system using:
# - AWS CodePipeline for workflow automation
# - TruffleHog for secret scanning
# - Multi-layered security with GitHub + AWS protection
# =============================================================================

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

# Configure AWS Provider
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = "production"
      ManagedBy   = "terraform"
      Purpose     = "secret-detection-pipeline"
    }
  }
}

# =============================================================================
# CORE MODULES - Building blocks of the security pipeline
# =============================================================================

# Secure storage for secrets and configuration
module "secrets" {
  source = "./modules/secrets"
  
  project_name = var.project_name
}

# S3 buckets for pipeline artifacts (encrypted)
module "storage" {
  source = "./modules/storage"
  
  project_name = var.project_name
}

# IAM roles with least-privilege access
module "iam" {
  source = "./modules/iam"
  
  project_name  = var.project_name
  secret_arn    = module.secrets.secret_arn
  parameter_arn = module.secrets.parameter_arn
}

# CodeBuild project for TruffleHog scanning
module "cicd" {
  source = "./modules/cicd"
  
  project_name           = var.project_name
  codebuild_role_arn     = module.iam.codebuild_role_arn
  codepipeline_role_arn  = module.iam.codepipeline_role_arn
  artifacts_bucket_name  = module.storage.artifacts_bucket_name
  source_bucket_name     = module.storage.source_bucket_name
  sns_topic_arn         = module.notifications.sns_topic_arn
}

# Email notifications for security alerts
module "notifications" {
  source = "./modules/notifications"
  
  project_name      = var.project_name
  notification_email = var.notification_email
  pipeline_name     = aws_codepipeline.ml_secrets_pipeline.name
}