resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "NexusCore_vpc" }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "NexusCore_igw" }
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  tags                    = { Name = "NexusCore_subnet_public_${count.index + 1}" }
}

resource "aws_subnet" "private_compute" {
  count                   = length(var.private_compute_subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_compute_subnets[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false
  tags                    = { Name = "NexusCore_subnet_private_compute_${count.index + 1}" }
}

resource "aws_subnet" "private_db" {
  count                   = length(var.private_db_subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_db_subnets[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false
  tags                    = { Name = "NexusCore_subnet_private_db_${count.index + 1}" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = { Name = "NexusCore_rt_public" }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private_compute" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "NexusCore_rt_private_compute" }
}

resource "aws_route_table_association" "private_compute" {
  count          = length(aws_subnet.private_compute)
  subnet_id      = aws_subnet.private_compute[count.index].id
  route_table_id = aws_route_table.private_compute.id
}

resource "aws_route_table" "private_db" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "NexusCore_rt_private_db" }
}

resource "aws_route_table_association" "private_db" {
  count          = length(aws_subnet.private_db)
  subnet_id      = aws_subnet.private_db[count.index].id
  route_table_id = aws_route_table.private_db.id
}