# Provider.tf
terraform {
  required_version = "~> 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"

  default_tags {
    tags = {
      Environment = "Test"
      Terraform = true
    }
  }
}

resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
}