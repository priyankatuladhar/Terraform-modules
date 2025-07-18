# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(var.common_tags, {
    Name = var.vpc_name
  })
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  count  = var.create_igw ? 1 : 0
  vpc_id = aws_vpc.main.id

  tags = merge(var.common_tags, {
    Name = "${var.vpc_name}-igw"
  })
}

# Public Subnets
resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge(var.common_tags, {
    Name = "${var.vpc_name}-public-${count.index + 1}"
    Type = "Public"
  })
}

# Private Subnets
resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(var.common_tags, {
    Name = "${var.vpc_name}-private-${count.index + 1}"
    Type = "Private"
  })
}

# Database Subnets
resource "aws_subnet" "database" {
  count = length(var.database_subnets)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.database_subnets[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(var.common_tags, {
    Name = "${var.vpc_name}-db-${count.index + 1}"
    Type = "Database"
  })
}

# NAT Gateway
resource "aws_eip" "nat" {
  count  = var.enable_nat_gateway ? var.single_nat_gateway ? 1 : length(var.public_subnets) : 0
  domain = "vpc"

  tags = merge(var.common_tags, {
    Name = "${var.vpc_name}-nat-eip-${count.index + 1}"
  })

  depends_on = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "main" {
  count = var.enable_nat_gateway ? var.single_nat_gateway ? 1 : length(var.public_subnets) : 0

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[var.single_nat_gateway ? 0 : count.index].id

  tags = merge(var.common_tags, {
    Name = "${var.vpc_name}-nat-${count.index + 1}"
  })

  depends_on = [aws_internet_gateway.main]
}

# Route Tables
resource "aws_route_table" "public" {
  count  = length(var.public_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.main.id

  tags = merge(var.common_tags, {
    Name = "${var.vpc_name}-public-rt"
  })
}

resource "aws_route_table" "private" {
  count  = var.enable_nat_gateway ? var.single_nat_gateway ? 1 : length(var.private_subnets) : length(var.private_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.main.id

  tags = merge(var.common_tags, {
    Name = "${var.vpc_name}-private-rt-${count.index + 1}"
  })
}

resource "aws_route_table" "database" {
  count  = length(var.database_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.main.id

  tags = merge(var.common_tags, {
    Name = "${var.vpc_name}-db-rt"
  })
}

# Routes
resource "aws_route" "public_internet_gateway" {
  count                  = length(var.public_subnets) > 0 && var.create_igw ? 1 : 0
  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main[0].id
}

resource "aws_route" "private_nat_gateway" {
  count                  = var.enable_nat_gateway ? var.single_nat_gateway ? 1 : length(var.private_subnets) : 0
  route_table_id         = aws_route_table.private[var.single_nat_gateway ? 0 : count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[var.single_nat_gateway ? 0 : count.index].id
}

# Route Table Associations
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[var.single_nat_gateway ? 0 : count.index].id
}

resource "aws_route_table_association" "database" {
  count          = length(var.database_subnets)
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database[0].id
}

# Data Sources
data "aws_availability_zones" "available" {
  state = "available"
}
    