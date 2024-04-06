locals {
  ami_west2_image = data.aws_ami.ubuntu_west2.name # described in data.tf
}

locals {
  available_azs = data.aws_availability_zones.available.names # described here
}
data "aws_availability_zones" "available" {} 

resource "aws_vpc" "vault_vpc" {
  cidr_block           = var.vpc_cidrblock
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "vault_vpc"
  }
}

resource "aws_subnet" "vault_subnet" {
  vpc_id                  = aws_vpc.vault_vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidrblock, 8, 11)
  availability_zone       = local.available_azs[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "vault_subnet_A1"
  }
}

resource "aws_internet_gateway" "vault-IG" {
  vpc_id = aws_vpc.vault_vpc.id
  tags = {
    Name = "ethernet_for_vpc"
  }
}

resource "aws_route_table" "vault_route_table" { 
  vpc_id = aws_vpc.vault_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vault-IG.id
  }

  depends_on = [aws_internet_gateway.vault-IG]
  tags = {
    Name = "route_table_for_vpc"
  }
}

resource "aws_route_table_association" "routeT_attach" {
  subnet_id      = aws_subnet.vault_subnet.id
  route_table_id = aws_route_table.vault_route_table.id
  depends_on     = [aws_route_table.vault_route_table]
}

# SECURITY GROUPS

resource "aws_security_group" "vault_sg" {
  name        = "vaultfirewall"
  description = "second SG created for vault cluster"
  vpc_id      = aws_vpc.vault_vpc.id
  tags = {
    Name = "my_vault_sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_8200" {
  ip_protocol       = "tcp"
  security_group_id = aws_security_group.vault_sg.id
  cidr_ipv4         = var.whitelisted_sg_outbound_cidr
  from_port         = 8200
  to_port           = 8200
}

resource "aws_vpc_security_group_ingress_rule" "allow_8201" {
  ip_protocol       = "tcp"
  security_group_id = aws_security_group.vault_sg.id
  cidr_ipv4         = var.whitelisted_sg_outbound_cidr
  from_port         = 8201
  to_port           = 8201
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  ip_protocol       = "tcp"
  security_group_id = aws_security_group.vault_sg.id
  cidr_ipv4         = var.whitelisted_sg_outbound_cidr
  from_port         = 22
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_outtrafic" {
  ip_protocol       = "-1"
  security_group_id = aws_security_group.vault_sg.id
  cidr_ipv4         = var.whitelisted_sg_outbound_cidr
}