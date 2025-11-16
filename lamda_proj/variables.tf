variable "region" {
  description = "AWS region to deploy SageMaker"
  type        = string
  default     = "eu-west-2"
}


variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
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

# variable "s3_bucket_name" {
#   description = "Name of the S3 bucket to store SNS logs (must be globally unique)"
#   type        = string
#   default     = "demo-sns-logs-${random_id.bucket_suffix.hex}"
# }

variable "notification_email" {
  description = "Email address to receive SNS email notifications (subscription requires confirmation)"
  type        = string
  default     = "you@example.com"
}

# helper random for default bucket name uniqueness