# ------------------------------------------------------
# VPC
# ------------------------------------------------------
resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "${var.project_name}-VPC" }
}

# ------------------------------------------------------
# Public Subnet 1
# ------------------------------------------------------
resource "aws_subnet" "public_subnet_one" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = { Name = "${var.project_name}-PublicSubnetOne" }
}

# ------------------------------------------------------
# Internet Gateway + Public Route Table
# ------------------------------------------------------
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = { Name = "${var.project_name}-IGW" }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = { Name = "${var.project_name}-PublicRouteTable" }
}

resource "aws_route_table_association" "public_rt_attach" {
  subnet_id      = aws_subnet.public_subnet_one.id
  route_table_id = aws_route_table.public_rt.id
}

# ------------------------------------------------------
# Private Subnet 1
# ------------------------------------------------------
resource "aws_subnet" "private_subnet_one" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.11.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = { Name = "${var.project_name}-PrivateSubnetOne" }
}

# ------------------------------------------------------
# Private Route Table
# ------------------------------------------------------
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main_vpc.id

  tags = { Name = "${var.project_name}-PrivateRouteTable" }
}

resource "aws_route_table_association" "private_rt_attach" {
  subnet_id      = aws_subnet.private_subnet_one.id
  route_table_id = aws_route_table.private_rt.id
}