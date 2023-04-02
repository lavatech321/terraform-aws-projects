#Create EC2 instances
module "ec2_instances" {
  source    = "./modules/00_ec2_instances"
}
output "az-public_ip" {
	value = "${module.ec2_instances.display_instance_public_ip}"
}
output "ids" {
	value = "${module.ec2_instances.ids}"
}

#Create target groups
module "target_groups" {
  depends_on = [ module.ec2_instances ]
  source    = "./modules/01_target_groups"
  instance_id = module.ec2_instances.ids
  vpc_id = module.ec2_instances.vpc_id
}

#Create application load balancer
module "app_load_balancer" {
  source    = "./modules/02_application_lb"
  target_id = module.target_groups.target_id
  vpc_id = module.ec2_instances.vpc_id
}

output "loadbalancer-dns" {
	value = "${module.app_load_balancer.dns}"
}

