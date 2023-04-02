resource "aws_key_pair" "key1" {
	key_name = "a12ansi123"
	public_key = "${file("/root/.ssh/id_rsa.pub")}"
}

# get current AMI
data "aws_ami" "amazon-linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }
}

resource "aws_instance" "ec2" {
	depends_on = [ aws_key_pair.key1 ]
	count = 2
	key_name = aws_key_pair.key1.key_name
	ami = data.aws_ami.amazon-linux.id
	instance_type = "t2.micro"
	subnet_id = data.aws_subnets.subnet.ids.0
	vpc_security_group_ids = ["${aws_security_group.nfs-settings.id}"] 
	tags = {
		Name = "clones-webserver"
	}
}

# Create EFS in current region
resource "aws_efs_file_system" "efs" {
  creation_token = "web-efs"
  encrypted = "true"
  tags = {
    Name = "Web EFS"
  }
}

# Creating Mount target of EFS
resource "aws_efs_mount_target" "mount" {
	file_system_id = aws_efs_file_system.efs.id
	subnet_id       = aws_instance.ec2[0].subnet_id
	security_groups = [aws_security_group.nfs-settings.id]
}

# Creating Mount Point for EFS
resource "null_resource" "configure_nfs" {
	count = length(aws_instance.ec2)
	depends_on = [ aws_efs_mount_target.mount, aws_instance.ec2]
	provisioner "remote-exec" {
		connection {
			type     = "ssh"
			user     = "ec2-user"
			private_key = "${file("/root/.ssh/id_rsa")}"
			host     = "${aws_instance.ec2[count.index].public_ip}"
	 	}
		inline = [
			"sudo yum install httpd -y",
			"sudo systemctl start httpd",
			"sudo systemctl enable httpd",
			"sudo yum install nfs-utils -y -q ",
			# Mounting Efs 
			"sudo mount -t nfs -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${aws_efs_file_system.efs.dns_name}:/  /var/www/html",
			# Making Mount Permanent
			"sudo echo ${aws_efs_file_system.efs.dns_name}:/ /var/www/html nfs4 defaults,_netdev 0 0   >> /etc/fstab " ,
			"sudo chmod go+rw /var/www/html",
			"sudo echo 'Welcome Back!' > /var/www/html/index.html",
  		]
		# In order to run this section everytime, use this block
 	}
	# In order to run this section everytime, use this block
	triggers = {
   		 always_run = timestamp()
	}
}

output "ec2-instance-ips" {
	value = [ for instance in aws_instance.ec2: instance.public_ip ]
}

