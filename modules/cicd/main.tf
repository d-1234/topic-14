# CodeBuild project for secret scanning only
resource "aws_codebuild_project" "ml_security_scan" {
  name         = "${var.project_name}-security-scan"
  service_role = var.codebuild_role_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:5.0"
    type         = "LINUX_CONTAINER"
  }

  source {
    type = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }
}