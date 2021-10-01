provider "aws" {
  region = "us-east-2"
}

resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "dev-test"
  }
}
