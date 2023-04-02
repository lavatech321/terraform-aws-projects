variable "sub_private" {}
variable "sub_public" {}

data "aws_ami" "ami1" {
	owners = ["amazon"]
	most_recent = true
	filter {
		name = "name"
		values = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
	}
}

resource "aws_key_pair" "key1" {
	key_name = "key1234"
	public_key = "${file("/root/.ssh/id_rsa.pub")}"
}

resource "aws_instance" "ec21" {
	ami = data.aws_ami.ami1.id
	instance_type = "t2.micro"
	key_name = "${aws_key_pair.key1.key_name}"
	vpc_security_group_ids = ["${aws_security_group.ssh.id}"]
	subnet_id = var.sub_public
	tags = {
		Name = "ec2-public"
	}
}

resource "aws_instance" "ec22" {
	ami = data.aws_ami.ami1.id
	instance_type = "t2.micro"
	key_name = "${aws_key_pair.key1.key_name}"
	vpc_security_group_ids = ["${aws_security_group.ssh.id}"]
	subnet_id = var.sub_private
	tags = {
		Name = "ec2-private"
	}
}

output "pub_public_ip" {
	value = aws_instance.ec21.public_ip
}

output "pub_private_ip" {
	value = aws_instance.ec21.private_ip
}
output "pri_private_ip" {
	value = aws_instance.ec22.private_ip
}
output "pri_public_ip" {
	value = aws_instance.ec22.public_ip
}

