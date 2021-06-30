provider "aws" {
  region = "ap-northeast-1"
}

terraform {
  required_version = "1.0.1"

  required_providers {
    aws = {
      source  = "aws"
      version = "~> 3"
    }
  }

  backend "s3" {
    bucket  = "research-devops"
    key     = "terraform/staging.tfstate"
    region  = "ap-northeast-1"
    encrypt = true
  }
}
