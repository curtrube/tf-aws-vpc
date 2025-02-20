locals {
  name         = lower(var.name)
  subnet_tiers = max(1, (var.enable_public ? 1 : 0) + (var.enable_private ? 1 : 0) + (var.enable_isolated ? 1 : 0))
  network_bits = ceil(log(var.az_count * local.subnet_tiers, 2))
  public_subnet_count = var.enable_public ? var.az_count : 0
  private_subnet_count = var.enable_private ? var.az_count : 0
}

################################################################################
# VPC
################################################################################

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

################################################################################
# Subnets
################################################################################

resource "aws_subnet" "public" {
  count = var.enable_public ? var.az_count : 0

  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  cidr_block              = cidrsubnet(var.cidr_block, local.network_bits, count.index)
  map_public_ip_on_launch = var.enable_public ? true : false
  vpc_id                  = aws_vpc.main.id

  tags = {
    Name = "${local.name}-public-subnet-${element(data.aws_availability_zones.available.names, count.index)}"
  }
}

resource "aws_subnet" "private" {
  count = var.enable_private ? var.az_count : 0

  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  cidr_block        = cidrsubnet(var.cidr_block, local.network_bits, count.index + local.subnet_tiers)
  vpc_id            = aws_vpc.main.id

  tags = {
    Name = "${local.name}-private-subnet-${element(data.aws_availability_zones.available.names, count.index)}"
  }
}

resource "aws_subnet" "isolated" {
  count = var.enable_isolated ? var.az_count : 0

  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  cidr_block        = cidrsubnet(var.cidr_block, local.network_bits, count.index + local.subnet_tiers * 2)
  vpc_id            = aws_vpc.main.id

  tags = {
    Name = "${local.name}-isolated-subnet-${element(data.aws_availability_zones.available.names, count.index)}"
  }
}

################################################################################
# Routes
################################################################################

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

    #route {
    #  ipv6_cidr_block        = "::/0"
    #  egress_only_gateway_id = aws_egress_only_internet_gateway.example.id
    #}

  tags = {
    Name = "${local.name}-public-route-table"
  }
}

resource "aws_route_table_association" "pubic" {
  count = var.enable_public ? var.az_count : 0

  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public[count.index].id
}

resource aws_route_table "private" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "${local.name}-private-route-table"
    }
}

resource "aws_route_table_association" "private" {
  count = var.enable_private ? var.az_count : 0

  route_table_id = aws_route_table.private.id
  subnet_id      = aws_subnet.private[count.index].id
}

# TODO: add isolated subnets route table / association
