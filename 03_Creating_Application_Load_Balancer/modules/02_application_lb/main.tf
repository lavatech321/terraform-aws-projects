variable "vpc_id" {}
variable "target_id" {}

# Find all subnets in the default vpc
data "aws_subnets" "example" {
  filter {
    name   = "vpc-id"
    values = ["${var.vpc_id}"]
  }
}

resource "aws_security_group" "allow-apache2" {
        name = "allow-http245343435"
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

# Create application load balancer and add subnet to it
resource "aws_lb" "apache_lb" {
    name               = "application-webserver"
    internal           = false
    load_balancer_type = "application"
    security_groups    = [aws_security_group.allow-apache2.id]
    subnets            = "${data.aws_subnets.example.ids}"
    enable_cross_zone_load_balancing = "true"
    tags = {
         Role = "Sample-Application"
    }
}

# Attach target group arn to load balancer
resource "aws_lb_listener" "lb_listener_http" {
   load_balancer_arn    = aws_lb.apache_lb.id
   port                 = "80"
   protocol             = "HTTP"
   default_action {
   target_group_arn = var.target_id
    type             = "forward"
  }
}

output "dns" {
	value = "${aws_lb.apache_lb.dns_name}"
}

