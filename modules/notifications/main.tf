# SNS topic for pipeline notifications
resource "aws_sns_topic" "pipeline_notifications" {
  name = "${var.project_name}-pipeline-notifications"
  
  kms_master_key_id = "alias/aws/sns"
  
  tags = {
    Project     = var.project_name
    Environment = "production"
    Purpose     = "pipeline-notifications"
  }
}

resource "aws_sns_topic_subscription" "email_notification" {
  topic_arn = aws_sns_topic.pipeline_notifications.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

# CloudWatch Event Rule for pipeline failures
resource "aws_cloudwatch_event_rule" "pipeline_failure" {
  name = "${var.project_name}-pipeline-failure"
  description = "Trigger notifications on pipeline failures"

  event_pattern = jsonencode({
    source      = ["aws.codepipeline"]
    detail-type = ["CodePipeline Stage Execution State Change"]
    detail = {
      pipeline = [var.pipeline_name]
      state    = ["FAILED"]
    }
  })
  
  tags = {
    Project     = var.project_name
    Environment = "production"
    Purpose     = "pipeline-monitoring"
  }
}

# CloudWatch Event Rule for CodeBuild failures
resource "aws_cloudwatch_event_rule" "codebuild_failure" {
  name = "${var.project_name}-codebuild-failure"
  description = "Trigger notifications on CodeBuild failures"

  event_pattern = jsonencode({
    source      = ["aws.codebuild"]
    detail-type = ["CodeBuild Build State Change"]
    detail = {
      build-status = ["FAILED"]
      project-name = ["${var.project_name}-security-scan"]
    }
  })
  
  tags = {
    Project     = var.project_name
    Environment = "production"
    Purpose     = "build-monitoring"
  }
}

resource "aws_cloudwatch_event_target" "sns" {
  rule      = aws_cloudwatch_event_rule.pipeline_failure.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.pipeline_notifications.arn
}

resource "aws_cloudwatch_event_target" "sns_codebuild" {
  rule      = aws_cloudwatch_event_rule.codebuild_failure.name
  target_id = "SendToSNSCodeBuild"
  arn       = aws_sns_topic.pipeline_notifications.arn
}

# SNS topic policy to allow CloudWatch Events
resource "aws_sns_topic_policy" "pipeline_notifications_policy" {
  arn = aws_sns_topic.pipeline_notifications.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = ["events.amazonaws.com", "codebuild.amazonaws.com"]
        }
        Action   = "sns:Publish"
        Resource = aws_sns_topic.pipeline_notifications.arn
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

data "aws_caller_identity" "current" {}