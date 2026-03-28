module "ec2_instances" {
  source = "./modules/ec2_instances"

  ami_value     = var.ami_value
  instance_type = var.instance_type
}
