# Provider configuration
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Secrets module
module "secrets" {
  source = "./modules/secrets"
  
  project_name = var.project_name
}

# Storage module
module "storage" {
  source = "./modules/storage"
  
  project_name = var.project_name
}

# IAM module
module "iam" {
  source = "./modules/iam"
  
  project_name  = var.project_name
  secret_arn    = module.secrets.secret_arn
  parameter_arn = module.secrets.parameter_arn
}

# CI/CD module
module "cicd" {
  source = "./modules/cicd"
  
  project_name           = var.project_name
  codebuild_role_arn     = module.iam.codebuild_role_arn
  codepipeline_role_arn  = module.iam.codepipeline_role_arn
  artifacts_bucket_name  = module.storage.artifacts_bucket_name
  source_bucket_name     = module.storage.source_bucket_name
}

# Notifications module
module "notifications" {
  source = "./modules/notifications"
  
  project_name      = var.project_name
  notification_email = var.notification_email
  pipeline_name     = aws_codepipeline.ml_secrets_pipeline.name
}