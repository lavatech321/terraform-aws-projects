module "vpc" {
	source = "./mods/vpc"
}

module "nat-gateway" {
	source = "./mods/nat"
	sub_public = module.vpc.sub_public
	sub_private = module.vpc.sub_private
	vpc_id = module.vpc.vpc_id
}

module "ec2" {
	source = "./mods/ec2"
	sub_public = module.vpc.sub_public
	sub_private = module.vpc.sub_private
	vpc_id = module.vpc.vpc_id
}

output "public-ec2-public-ip" {
	value = module.ec2.pub_public_ip
}

output "public-ec2-private-ip" {
	value = module.ec2.pub_private_ip
}

output "private-ec2-private-ip" {
	value = module.ec2.pri_private_ip
}

output "private-ec2-public-ip" {
	value = module.ec2.pri_public_ip
}

