data "aws_region" "current" {}
resource "aws_vpc" "prisjakt_vpc" {
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "prisjakt_public_subnet" {
  vpc_id            = aws_vpc.prisjakt_vpc.id
  cidr_block        = "10.1.0.0/24"
  availability_zone = "${data.aws_region.current.name}a"
}

resource "aws_subnet" "prisjakt_private_subnet_a" {
  vpc_id            = aws_vpc.prisjakt_vpc.id
  cidr_block        = "10.1.1.0/24"
  availability_zone = "${data.aws_region.current.name}a"
}

resource "aws_subnet" "prisjakt_private_subnet_b" {
  vpc_id            = aws_vpc.prisjakt_vpc.id
  cidr_block        = "10.1.2.0/24"
  availability_zone = "${data.aws_region.current.name}b"
}

resource "aws_internet_gateway" "internet_gw" {
  vpc_id = aws_vpc.prisjakt_vpc.id
}

resource "aws_route" "internet_route" {
  route_table_id         = aws_vpc.prisjakt_vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gw.id
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.prisjakt_public_subnet.id
  route_table_id = aws_vpc.prisjakt_vpc.main_route_table_id
}

resource "aws_route_table" "private_subnets_route_table" {
  vpc_id = aws_vpc.prisjakt_vpc.id
}

resource "aws_route_table_association" "private_subnet_a_association" {
  subnet_id      = aws_subnet.prisjakt_private_subnet_a.id
  route_table_id = aws_route_table.private_subnets_route_table.id
}

resource "aws_route_table_association" "private_subnet_b_association" {
  subnet_id      = aws_subnet.prisjakt_private_subnet_b.id
  route_table_id = aws_route_table.private_subnets_route_table.id
}

module "bastion_host" {
  source           = "./bastion_host"
  vpc_id           = aws_vpc.prisjakt_vpc.id
  public_subnet_id = aws_subnet.prisjakt_public_subnet.id
  vpc_name         = var.vpc_name
}
