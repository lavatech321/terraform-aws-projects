# This is a resource block and it's where you define VPC resources.
resource "aws_vpc" "newvpc" {
	cidr_block = "172.90.0.0/16"
	tags = {
		Name = "newvpc"
	}
}

resource "aws_subnet" "sub-private" {
	vpc_id     = aws_vpc.newvpc.id
	cidr_block = "172.90.1.0/24"
	tags = {
		Name = "sub-private"
	}
}

resource "aws_subnet" "sub-public" {
	vpc_id     = aws_vpc.newvpc.id
	cidr_block = "172.90.2.0/24"
	tags = {
		Name = "sub-public"
	}
	map_public_ip_on_launch = true
}

# Create Internet gateway and attach it VPC
resource "aws_internet_gateway" "gw" {
	vpc_id = aws_vpc.newvpc.id
	tags = {
		Name = "new-ig"
	}
}

resource "aws_route_table" "new_route_table" {
	vpc_id = aws_vpc.newvpc.id
	tags = {
		Name = "new-route-table"
	}
}

resource "aws_route" "route" {
	route_table_id = aws_route_table.new_route_table.id
	destination_cidr_block = "0.0.0.0/0"
	gateway_id = aws_internet_gateway.gw.id
}

resource "aws_route_table_association" "sub_association" {
  subnet_id = aws_subnet.sub-public.id
  route_table_id = aws_route_table.new_route_table.id
}

output "vpc_id" {
	value = aws_vpc.newvpc.id
}

output "sub_public" {
	value = aws_subnet.sub-public.id
}

output "sub_private" {
	value = aws_subnet.sub-private.id
}

