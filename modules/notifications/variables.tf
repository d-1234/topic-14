variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "notification_email" {
  description = "Email for pipeline notifications"
  type        = string
}

variable "pipeline_name" {
  description = "Name of the CodePipeline to monitor"
  type        = string
}