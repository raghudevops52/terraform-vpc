resource "aws_vpc" "main" {
  cidr_block            = var.VPC_CIDR
  enable_dns_hostnames  = true
  enable_dns_support    = true
  tags                  = {
    Name                = "rb-${var.ENV}-vpc"
  }
}

resource "aws_subnet" "public" {
  count                 = 2
  vpc_id                = aws_vpc.main.id
  cidr_block            = local.SUBNET_CIDR[count.index]
  availability_zone     = element(var.AZS, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name                = "rb-${var.ENV}-public-subnet-${count.index+1}"
  }
}

resource "aws_subnet" "private" {
  count                 = 6
  vpc_id                = aws_vpc.main.id
  cidr_block            = local.SUBNET_CIDR[count.index+2]
  availability_zone     = element(var.AZS, count.index)

  tags = {
    Name                = "rb-${var.ENV}-private-subnet-${count.index+1}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id                = aws_vpc.main.id

  tags                  = {
    Name                = "rb-${var.ENV}-igw"
  }
}

resource "aws_route_table" "public-rt" {
  vpc_id                = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  route {
    cidr_block          = data.aws_vpc.default.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
  }

  tags                  = {
    Name                = "rb-${var.ENV}-public-rt"
  }
}

resource "aws_route_table_association" "public-rt-assoc" {
  count                 = 2
  subnet_id             = aws_subnet.public.*.id[count.index]
  route_table_id        = aws_route_table.public-rt.id
}

resource "aws_eip" "nat" {}

resource "aws_nat_gateway" "ngw" {
  allocation_id         = aws_eip.nat.id
  subnet_id             = aws_subnet.public.*.id[0]

  tags                  = {
    Name                = "rb-${var.ENV}-ngw"
  }
}

resource "aws_route_table" "private-rt" {
  vpc_id                = aws_vpc.main.id

  route {
    cidr_block          = "0.0.0.0/0"
    nat_gateway_id      = aws_nat_gateway.ngw.id
  }

  route {
    cidr_block          = data.aws_vpc.default.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
  }

  tags                  = {
    Name                = "rb-${var.ENV}-private-rt"
  }
}

resource "aws_route_table_association" "private-rt-assoc" {
  count                 = 6
  subnet_id             = aws_subnet.private.*.id[count.index]
  route_table_id        = aws_route_table.private-rt.id
}


resource "aws_vpc_peering_connection" "peering" {
  peer_owner_id         = data.aws_caller_identity.current.account_id
  peer_vpc_id           = var.DEFAULT_VPC_ID
  vpc_id                = aws_vpc.main.id
  auto_accept           = true
}

// Adding route for default vpc

resource "aws_route" "add-peering-to-default-vpc" {
  count                     = length(data.aws_route_tables.rts.ids)
  route_table_id            = element(tolist(data.aws_route_tables.rts.ids), count.index )
  destination_cidr_block    = var.VPC_CIDR
  vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
}
