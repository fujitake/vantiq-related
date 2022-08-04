###
###  VPC
###
resource "aws_vpc" "vantiq-vpc" {
  cidr_block           = var.vpc_cidr_block # "172.20.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    KubernetesCluster                           = var.cluster_name
    Name                                        = "${var.env_name}-${var.cluster_name}-vpc"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

###
###  Public Subnet x 3(az)
###
resource "aws_subnet" "public" {
  for_each          = var.public_subnet_config
  vpc_id            = aws_vpc.vantiq-vpc.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone

  tags = {
    KubernetesCluster                               = var.cluster_name
    Name                                            = "${var.env_name}-${var.cluster_name}-public-${each.key}"
    SubnetType                                      = "Public"
    "kubernetes.io/cluster/${var.cluster_name}"     = "shared"
    "kubernetes.io/role/${var.subnet_roles.public}" = "1"
  }
}

###
###  Private Subnet x 3(az)
###
resource "aws_subnet" "private" {
  for_each          = var.private_subnet_config
  vpc_id            = aws_vpc.vantiq-vpc.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone

  tags = {
    KubernetesCluster                                = var.cluster_name
    Name                                             = "${var.env_name}-${var.cluster_name}-private-${each.key}"
    SubnetType                                       = "Private"
    "kubernetes.io/cluster/${var.cluster_name}"      = "shared"
    "kubernetes.io/role/${var.subnet_roles.private}" = "1"
  }
}

###
###  Internet Gateway (Public Subnet Default Gateway)
###
resource "aws_internet_gateway" "vantiq-igw" {
  vpc_id = aws_vpc.vantiq-vpc.id

  tags = {
    KubernetesCluster                           = var.cluster_name
    Name                                        = "${var.env_name}-${var.cluster_name}-igw"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

###
###  Elastic IP (for Public Subnet NAT Gateway x 3az)
###
resource "aws_eip" "public-natgw-eip" {
  for_each = var.public_subnet_config
  vpc      = true

  tags = {
    KubernetesCluster                           = var.cluster_name
    Name                                        = "${var.env_name}-${var.cluster_name}-eip-${each.key}"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

###
###  NAT Gateway (Public Subnet x 3 az)
###
resource "aws_nat_gateway" "public" {
  for_each      = var.public_subnet_config
  allocation_id = aws_eip.public-natgw-eip[each.key].id
  subnet_id     = aws_subnet.public[each.key].id

  tags = {
    KubernetesCluster                           = var.cluster_name
    Name                                        = "${var.env_name}-${var.cluster_name}-natgw-${each.key}"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

###
###  Route table (for each public subnet x 3az)
### 
resource "aws_route_table" "public" {
  for_each = var.public_subnet_config
  vpc_id   = aws_vpc.vantiq-vpc.id

  tags = {
    Name = "${var.env_name}-${var.cluster_name}-public-${each.key}"
  }
}

resource "aws_route" "public" {
  for_each               = var.public_subnet_config
  route_table_id         = aws_route_table.public[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.vantiq-igw.id
}

resource "aws_route_table_association" "public" {
  for_each       = var.public_subnet_config
  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public[each.key].id
}

###
###  Route table (for each private subnet x 3az)
### 
resource "aws_route_table" "private" {
  for_each = var.private_subnet_config
  vpc_id   = aws_vpc.vantiq-vpc.id

  tags = {
    Name = "${var.env_name}-${var.cluster_name}-private-${each.key}"
  }
}

resource "aws_route" "private" {
  for_each               = var.private_subnet_config
  route_table_id         = aws_route_table.private[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.public[each.key].id
}

resource "aws_route_table_association" "private" {
  for_each       = var.private_subnet_config
  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}


