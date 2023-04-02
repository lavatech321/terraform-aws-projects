data "aws_instance" "web" {
	# Filter tag of existing running EC2 instance
        filter {
                name = "tag:Name"
                values = ["new-web"]
        }
        filter {
                name = "instance-state-name"
                values = ["running"]
        }
}

resource "aws_ami_from_instance" "ex1" {
        source_instance_id = "${data.aws_instance.web.id}"
        name = "web-backup"
	tags = {
		Name = "web-backup"
	}
}

