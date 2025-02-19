locals {
  name         = lower(var.name)
  subnet_tiers = max(1, (var.enable_public ? 1 : 0) + (var.enable_private ? 1 : 0) + (var.enable_isolated ? 1 : 0))
  network_bits = ceil(log(var.az_count * local.subnet_tiers, 2))
}

output "network_bits" {
    value = local.network_bits
}

output "tiers" {
    value = local.subnet_tiers
}

variable "enable_public" {
    type = bool
    default = true
    description = "Whether to create public subnets."
}

variable "enable_private" {
    type = bool
    default = true
    description = "Whether to create private subnets."
}

variable "enable_isolated" {
    type = bool
    default = true
    description = "Whether to create isolated subnets."
}

resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  instance_tenancy     = "default"

  tags = {
    Name = "${local.name}-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.name}-igw"
  }
}

resource "aws_subnet" "public" {
  count = var.az_count

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.cidr_block, local.network_bits, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = "${local.name}-public-subnet-${element(data.aws_availability_zones.available.names, count.index)}"
  }
}

resource "aws_subnet" "private" {
  count = var.az_count

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.cidr_block, local.network_bits, count.index + local.subnet_tiers)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = "${local.name}-private-subnet-${element(data.aws_availability_zones.available.names, count.index)}"
  }
}

resource "aws_subnet" "isolated" {
  count = var.az_count

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.cidr_block, local.network_bits, count.index + local.subnet_tiers * 2)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = "${local.name}-isolated-subnet-${element(data.aws_availability_zones.available.names, count.index)}"
  }
}
