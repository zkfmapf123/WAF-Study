resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "waf-study-vpc"
  }
}

resource "aws_subnet" "public" {
  for_each = {
    "ap-northeast-2a" = "10.0.1.0/24",
    "ap-northeast-2b" = "10.0.2.0/24"
  }

  vpc_id            = aws_vpc.main.id
  availability_zone = each.key
  cidr_block        = each.value

  map_public_ip_on_launch = true

  tags = {
    Name = "waf-stduy-publuc-${each.key}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "waf-study-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value["id"]
  route_table_id = aws_route_table.public.id
}
