resource "aws_vpc" "vpc" {
  cidr_block              = var.vpc_cidr
  enable_dns_support      = true
  enable_dns_hostnames    = true

  tags                    = {
    Name                  = "${var.project}-vpc"
  }
}

resource "aws_subnet" "subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, 0)
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags                    = {
    Name                  = "${var.project}-subnet"
  }
  
  depends_on              = [aws_vpc.vpc]
}

resource "aws_internet_gateway" "igw" {
  vpc_id                  = aws_vpc.vpc.id

  tags                    = {
    Name                  = "${var.project}-igw"
  }

  depends_on              = [aws_vpc.vpc]
}

resource "aws_route_table" "route_table" {
  vpc_id                  = aws_vpc.vpc.id
  route {
    cidr_block            = "0.0.0.0/0"
    gateway_id            = aws_internet_gateway.igw.id
  }

  tags                    = {
    Name                  = "${var.project}-route-table"
  }

  depends_on              = [aws_vpc.vpc]
}

resource "aws_route_table_association" "route_table_association" {
  subnet_id               = aws_subnet.subnet.id
  route_table_id          = aws_route_table.route_table.id

  depends_on              = [aws_subnet.subnet, aws_route_table.route_table]
}