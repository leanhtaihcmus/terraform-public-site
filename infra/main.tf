terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 4.36.1"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}