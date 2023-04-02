variable "instance_id" {}
variable "vpc_id" {}

# Map used for providing details for health-check
# You can use the values based on your requirements
variable "health_check" {
   type = map(string)
   default = {
      "timeout"  = "10"
      "interval" = "20"
      "path"     = "/"
      "port"     = "80"
      "unhealthy_threshold" = "2"
      "healthy_threshold" = "3"
    }
}

# Attach target group
resource "aws_lb_target_group" "tg" {
  name     = "app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
      healthy_threshold   = var.health_check["healthy_threshold"]
      interval            = var.health_check["interval"]
      unhealthy_threshold = var.health_check["unhealthy_threshold"]
      timeout             = var.health_check["timeout"]
      path                = var.health_check["path"]
      port                = var.health_check["port"]
  }
}

resource "aws_alb_target_group_attachment" "tg_attachment_test" {
	count = length(var.instance_id)
        target_group_arn = aws_lb_target_group.tg.arn
        target_id        = var.instance_id[count.index]
        port             = 80
}

output "target_id" {
	value = aws_lb_target_group.tg.id
}

