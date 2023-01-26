resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = var.vpc_tag
  }
}

resource "aws_subnet" "private-subnets" {
  count             = length(var.private-subnet_cidrs)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private-subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]
  tags = {
    Name = "private-subnet ${count.index}"
  }
}

resource "aws_subnet" "public-subnets" {
  count                   = length(var.public-subnet_cidrs)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public-subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet ${count.index}"
  }
}

resource "aws_route_table" "private-route-tables" {
  count  = 2
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "private-rt ${count.index}"
  }
}

resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "public-rt"
  }
}

resource "aws_route_table_association" "private-associations" {
  count          = 2
  subnet_id      = aws_subnet.private-subnets[count.index].id
  route_table_id = aws_route_table.private-route-tables[count.index].id
}

resource "aws_route_table_association" "public-associations" {
  count          = 2
  subnet_id      = aws_subnet.public-subnets[count.index].id
  route_table_id = aws_route_table.public-route-table.id
}

resource "aws_route" "private-route-with-nat" {
  count                  = 2
  route_table_id         = aws_route_table.private-route-tables[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ngw[count.index].id
}

resource "aws_route" "public-route-with-igw" {
  route_table_id         = aws_route_table.public-route-table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_eip" "nat-ips" {
  count = 2
  vpc   = true
  tags = {
    Name = "nat-eip ${count.index}"
  }
}

resource "aws_nat_gateway" "ngw" {
  count         = 2
  allocation_id = aws_eip.nat-ips[count.index].id
  subnet_id     = aws_subnet.public-subnets[count.index].id

  tags = {
    Name = "ngw ${count.index}"
  }
}

resource "aws_internet_gateway" "igw" {
  tags = {
    Name = "igw"
  }
}

resource "aws_internet_gateway_attachment" "igw-attatchment" {
  internet_gateway_id = aws_internet_gateway.igw.id
  vpc_id              = aws_vpc.vpc.id
}