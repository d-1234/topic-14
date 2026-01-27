# CodePipeline with GitHub source
resource "aws_codepipeline" "ml_secrets_pipeline" {
  name     = "${var.project_name}-pipeline"
  role_arn = module.iam.codepipeline_role_arn

  artifact_store {
    location = module.storage.artifacts_bucket_name
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        Owner      = var.github_owner
        Repo       = var.github_repo
        Branch     = var.github_branch
        OAuthToken = var.github_token
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
}