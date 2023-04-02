resource "aws_security_group" "all-port-open" {
        vpc_id = var.vpc_id
        name = "all-port-open"
        ingress {
                from_port = 0
                to_port = 0
                protocol = "-1"
                cidr_blocks = ["0.0.0.0/0"]
        }
        egress {
                from_port = 0
                to_port = 0
                protocol = "-1"
                cidr_blocks = ["0.0.0.0/0"]
        }
}

output "port-open" {
        value = aws_security_group.all-port-open.id
}

