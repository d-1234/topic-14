# =============================================================================
# SECRET DETECTION PIPELINE - INPUT VARIABLES
# =============================================================================
# Configure these variables in terraform.tfvars to customize your deployment
# =============================================================================

variable "aws_region" {
  description = "AWS region for deploying resources"
  type        = string
  default     = "us-east-1"
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.aws_region))
    error_message = "AWS region must be a valid region identifier."
  }
}

variable "project_name" {
  description = "Project name used for resource naming and tagging"
  type        = string
  default     = "ml-secrets-demo"
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name)) && length(var.project_name) <= 20
    error_message = "Project name must be lowercase alphanumeric with hyphens, max 20 characters."
  }
}

variable "github_owner" {
  description = "GitHub repository owner (username or organization)"
  type        = string
  
  validation {
    condition     = length(var.github_owner) > 0
    error_message = "GitHub owner cannot be empty."
  }
}

variable "github_repo" {
  description = "GitHub repository name containing the code to scan"
  type        = string
  
  validation {
    condition     = length(var.github_repo) > 0
    error_message = "GitHub repository name cannot be empty."
  }
}

variable "github_branch" {
  description = "GitHub branch to monitor for changes"
  type        = string
  default     = "main"
  
  validation {
    condition     = contains(["main", "master", "develop", "dev"], var.github_branch)
    error_message = "Branch must be one of: main, master, develop, dev."
  }
}

variable "notification_email" {
  description = "Email address for receiving security alerts and pipeline notifications"
  type        = string
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.notification_email))
    error_message = "Please provide a valid email address."
  }
}