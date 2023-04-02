data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "allow-ssh" {
	name = "ec2-allow-ssh"
	vpc_id = data.aws_vpc.default.id
	tags = {
		name = "ec2-allow-ssh"
	}
   	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
	ingress {
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
}

resource "aws_security_group" "allow-apache" {
	name = "ec2-allow-http"
	vpc_id = data.aws_vpc.default.id
	tags = {
		name = "ec2-allow-http"
	}
   	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}

	ingress {
		from_port = 80
		to_port = 80
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
}

output "vpc_id" {
	value = data.aws_vpc.default.id
}

