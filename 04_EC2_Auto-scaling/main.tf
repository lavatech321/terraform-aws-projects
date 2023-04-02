data "aws_vpc" "default" {
  default = true
}

# get all AZ in current region
data "aws_availability_zones" "available" {
  state = "available"
}

# get all subnets in default VPC
data "aws_subnet_ids" "subnet" {
  vpc_id = "${data.aws_vpc.default.id}"
}

data "aws_ami" "amazon-linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }
}

resource "aws_key_pair" "key1" {
	key_name = "sample456"
	public_key = file("/root/.ssh/id_rsa.pub")
}

resource "aws_launch_configuration" "terramino" {
  name_prefix     = "terraform-aws-asg-"
  image_id        = data.aws_ami.amazon-linux.id
  key_name 	  = aws_key_pair.key1.key_name
  instance_type   = "t2.micro"
  user_data       = file("user-data.sh")
  security_groups = [aws_security_group.terra-sg.id]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "terramino" {
  name                 = "terramino"
  min_size             = 2
  max_size             = 4
  desired_capacity     = 3
  launch_configuration = aws_launch_configuration.terramino.name
  vpc_zone_identifier  = data.aws_subnet_ids.subnet.ids
  tag {
    key                 = "Name"
    value               = "auto-insta"
    propagate_at_launch = true
  }
}

data "aws_instances" "auto" {
	depends_on = [ aws_autoscaling_group.terramino ]
	filter {
		name = "tag:Name"
    		values = ["auto-insta"]
	}
	filter {
		name = "instance-state-name"
		values = ["running"]
	}
}

resource "aws_lb_target_group" "terramino" {
  name     = "learn-asg-terramino"
  port     = 80
  protocol = "HTTP"
  vpc_id   =  data.aws_vpc.default.id
}

resource "aws_autoscaling_attachment" "terramino" {
  autoscaling_group_name = aws_autoscaling_group.terramino.id
  alb_target_group_arn   = aws_lb_target_group.terramino.arn
}

locals {
    depends_on = [ aws_autoscaling_group.terramino ]
    att_004 = join(" , ", data.aws_instances.auto.public_ips )
}

output "public_ips" {
    value = local.att_004
}

