# CodeStar Connection for GitHub
resource "aws_codestarconnections_connection" "github" {
  name          = "${var.project_name}-github"
  provider_type = "GitHub"
  
  tags = {
    Project     = var.project_name
    Environment = "production"
    Purpose     = "github-integration"
  }
}

# CodePipeline with GitHub source
resource "aws_codepipeline" "ml_secrets_pipeline" {
  name     = "${var.project_name}-pipeline"
  role_arn = module.iam.codepipeline_role_arn

  artifact_store {
    location = module.storage.artifacts_bucket_name
    type     = "S3"
    
    encryption_key {
      id   = aws_kms_alias.pipeline_kms_alias.arn
      type = "KMS"
    }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.github.arn
        FullRepositoryId = "${var.github_owner}/${var.github_repo}"
        BranchName       = var.github_branch
      }
    }
  }

  stage {
    name = "SecretScan"

    action {
      name             = "TruffleHogScan"
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
  
  tags = {
    Project     = var.project_name
    Environment = "production"
    Purpose     = "secret-detection-pipeline"
  }
}

# KMS key for pipeline encryption
resource "aws_kms_key" "pipeline_kms_key" {
  description             = "KMS key for ${var.project_name} pipeline encryption"
  deletion_window_in_days = 7
  
  tags = {
    Project     = var.project_name
    Environment = "production"
    Purpose     = "pipeline-encryption"
  }
}

resource "aws_kms_alias" "pipeline_kms_alias" {
  name          = "alias/${var.project_name}-pipeline"
  target_key_id = aws_kms_key.pipeline_kms_key.key_id
}