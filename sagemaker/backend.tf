terraform {
  backend "s3" {
    bucket         = "mlops-terraform-state-8bb607e1"    # replace with your bucket name
    key            = "sagemaker/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "mlops-terraform-locks"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.5.0"
}
