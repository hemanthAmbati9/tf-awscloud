

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}

variable "project_name" {
  description = "Project name prefix"
  type        = string
  default     = "demo"
}

variable "environment" {
  description = "Environment tag"
  type        = string
  default     = "dev"
}





variable "notification_email" {
  description = "Email address to subscribe to SNS topic (must confirm)"
  type        = string
  default     = "hemanthambati5@gmail.com" # set to a real email before apply
}
