# Get the existing EC2 instance details
data "aws_instance" "web" {
	filter {
		name = "tag:Name"
		values = ["new-web"]
	}
	filter {
		name = "instance-state-name"
		values = ["running"]
	}
}

# Get the Root volume id of existing EC2 instance
data "aws_ebs_volume" "web_vol" {
        filter {
                name = "attachment.instance-id"
                values = ["${data.aws_instance.web.id}"]
        }
}

resource "aws_ebs_snapshot" "snap1" {
	volume_id = "${data.aws_ebs_volume.web_vol.id}"
	tags = {
		Name = "new-web-snapshot"
	}
}

output "snap_id" {
        value = "new-web snapshot id is: ${aws_ebs_snapshot.snap1.id}"
}

