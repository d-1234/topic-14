variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "secret_arn" {
  description = "ARN of the Secrets Manager secret"
  type        = string
}

variable "parameter_arn" {
  description = "ARN of the SSM parameter"
  type        = string
}