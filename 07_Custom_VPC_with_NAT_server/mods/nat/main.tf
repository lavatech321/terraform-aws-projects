
variable "sub_public" {}
variable "sub_private" {}
variable "vpc_id" {}

# Select nat server AMI
data "aws_ami" "ami1" {
	owners = ["amazon"]
	most_recent = true
	filter {
		name = "name"
		values = ["amzn-ami-vpc-nat-*-ebs"]
	}
}

# Create aws key pair for nat server
resource "aws_key_pair" "key1" {
	key_name = "key123478"
	public_key = "${file("/root/.ssh/id_rsa.pub")}"
}


# Create NAT instance
resource "aws_instance" "nat_instance" {
  ami = "${data.aws_ami.ami1.id}"
  instance_type = "t2.micro"
  key_name = aws_key_pair.key1.key_name
  subnet_id = var.sub_public
  vpc_security_group_ids = [ aws_security_group.all-port-open.id ]
  source_dest_check = false
  tags = {
    Name = "nat-instance"
  }
  user_data = <<-EOF
              #!/bin/bash
              echo 1 > /proc/sys/net/ipv4/ip_forward
              iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
              EOF
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
  instance_id = aws_instance.nat_instance.id
}

# Associate private route table with private subnet
resource "aws_route_table_association" "private_association" {
  subnet_id = var.sub_private
  route_table_id = aws_route_table.private_route_table.id
}

