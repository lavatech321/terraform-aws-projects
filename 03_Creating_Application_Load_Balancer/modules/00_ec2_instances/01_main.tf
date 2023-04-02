# get current AMI
data "aws_ami" "amazon-linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }
}

locals {
 virtual_machines = {
   "web1" = { zone = "ap-northeast-1a" },
   "web2" = { zone = "ap-northeast-1c" },
   "web3" = { zone = "ap-northeast-1d" }
 }
}

resource "aws_key_pair" "key1" {
	key_name = "test3452452"
	public_key = "${file("/root/.ssh/id_rsa.pub")}"
}

resource "aws_instance" "newwebserver" {
        for_each = local.virtual_machines
        tags = {
                Name = each.key
        }
        availability_zone = each.value.zone
        ami = data.aws_ami.amazon-linux.id
        instance_type = "t2.micro"
        key_name = "${aws_key_pair.key1.key_name}"
        vpc_security_group_ids = ["${aws_security_group.allow-ssh.id}", aws_security_group.allow-apache.id]
	user_data = <<-EOF
	#!/bin/bash
	sudo yum install httpd -y
	sudo touch /var/www/html/index.html
	sudo echo "Welcome to terraform created application load balancer" >> /var/www/html/index.html 
	sudo systemctl restart httpd
	sudo systemctl enable httpd
	EOF
}

output "display_instance_public_ip" {
    	value = { for instance in aws_instance.newwebserver: instance.availability_zone => instance.public_ip }
}

output "ids" {
	value = [for instance  in aws_instance.newwebserver: instance.id]
}

