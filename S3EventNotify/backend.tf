terraform {
  backend "s3" {
    bucket         = "mlops-terraform-state-9334135d"    # replace with your bucket name
    key            = "lamda/terraform.tfstate"
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
