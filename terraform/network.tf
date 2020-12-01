resource "aws_vpc" "default" {
  cidr_block           = var.cidr
  enable_dns_hostnames = true

  tags = merge(local.common_tags, {Name = "${random_pet.name.id}-vpc"})
}

resource "aws_subnet" "default" {
  vpc_id     = aws_vpc.default.id
  cidr_block = var.cidr

  tags = merge(local.common_tags, {Name = "${random_pet.name.id}-subnet"})
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id

  tags = merge(local.common_tags, {Name = "${random_pet.name.id}-internet_gateway"})
}

resource "aws_route_table" "default" {
  vpc_id = aws_vpc.default.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }

  tags = merge(local.common_tags, {Name = "${random_pet.name.id}-route_table"})
}

resource "aws_route_table_association" "default" {
  subnet_id      = aws_subnet.default.id
  route_table_id = aws_route_table.default.id
}

resource "aws_key_pair" "default" {
  key_name   = "${random_pet.name.id}-ssh_public_key"
  public_key = var.ssh_public_key
}