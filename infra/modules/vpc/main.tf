
resource "aws_vpc" "nginx-vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "nginx-vpc"
  }
}

# Fetch AZs for the current region dynamically
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "private" {
  count      = 2
  vpc_id     = aws_vpc.nginx-vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr, 2, count.index)
  # Both private subnets ALSO use AZ index 0 and 1
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    "Name" = "nginx-private-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "public" {
  count      = 2
  vpc_id     = aws_vpc.nginx-vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr, 2, count.index + 2)
  # Both public subnets ALSO use AZ index 0 and 1
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    "Name" = "nginx-public-subnet-${count.index + 1}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.nginx-vpc.id
  tags = {
    Name = "nginx-public-rt"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.nginx-vpc.id
  tags = {
    Name = "nginx-igw"
  }
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public_subnet_association" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.nginx-vpc.id
  tags = {
    Name = "nginx-private-rt"
  }
}
data "aws_region" "current" {}
# --------------------------------------------------------------
# pull images from ECR so we need some vpc endpoints for that
# --------------------------------------------------------------
locals {
  interface_endpoints = {
    "ecr_api" = "com.amazonaws.${data.aws_region.current.name}.ecr.api",
    "ecr_dkr" = "com.amazonaws.${data.aws_region.current.name}.ecr.dkr",
    "logs"    = "com.amazonaws.${data.aws_region.current.name}.logs"
  }
}

resource "aws_vpc_endpoint" "interface" {
  for_each = local.interface_endpoints

  vpc_id              = aws_vpc.nginx-vpc.id
  service_name        = each.value
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  
  # Deploy ENIs into your private subnets
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]

  tags = {
    Name = "nginx-${each.key}-endpoint"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.nginx-vpc.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private.id]
  
  tags = { Name = "nginx-s3-endpoint" }
}

resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}


