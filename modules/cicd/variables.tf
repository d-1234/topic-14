variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "codebuild_role_arn" {
  description = "ARN of the CodeBuild IAM role"
  type        = string
}

variable "codepipeline_role_arn" {
  description = "ARN of the CodePipeline IAM role"
  type        = string
}

variable "artifacts_bucket_name" {
  description = "Name of the S3 bucket for artifacts"
  type        = string
}

variable "source_bucket_name" {
  description = "Name of the S3 bucket for source code"
  type        = string
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic for notifications"
  type        = string
  default     = ""
}