data "aws_vpc" "default" {
	default = "true"
}
data "aws_subnets" "subnet" {
  filter {
	name = "vpc-id"
	values = [ "${data.aws_vpc.default.id}" ]
  }
}
resource "aws_security_group" "nfs-settings" {
	name = "sg12344590"
	vpc_id = data.aws_vpc.default.id
	tags = {
		Name = "nfs-http-ssh"
	}
	ingress {
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
	ingress {
		from_port = 80
		to_port = 80
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
	ingress {
		from_port = 2049
		to_port = 2049
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
}
output "subnets" {
	value = data.aws_subnets.subnet
}

