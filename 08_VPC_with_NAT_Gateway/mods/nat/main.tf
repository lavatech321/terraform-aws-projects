variable "sub_public" {}
variable "sub_private" {}
variable "vpc_id" {}

# Create Elastic IP for NAT gateway
resource "aws_eip" "eip" {
  vpc = true
}

# Create NAT gateway
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.eip.id
  #subnet_id = aws_subnet.public_subnet.id
  subnet_id = var.sub_public
}

# Create route table for private subnet and nat server
resource "aws_route_table" "private_route_table" {
  vpc_id = var.vpc_id
  tags = {
    Name = "private-route-table"
  }
}

# Add route to private route table for NAT instance
resource "aws_route" "private_nat_route" {
  route_table_id = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat_gateway.id
}

# Associate private route table with private subnet
resource "aws_route_table_association" "private_association" {
  subnet_id = var.sub_private
  route_table_id = aws_route_table.private_route_table.id
}

