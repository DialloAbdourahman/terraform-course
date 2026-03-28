// Main VPC
module "vpc" {
  source = "./modules/vpc"

  vpc_name = terraform.workspace == "dev" ? var.dev_vpc_name : var.prod_vpc_name
  vpc_cidr = var.vpc_cidr
  add_igw  = true
}

// Subnets
module "public_subnet_az1" {
  source = "./modules/subnet"

  vpc_id                  = module.vpc.vpc_id
  subnet_cidr             = "10.0.0.0/24"
  subnet_name             = "public_subnet_one"
  availability_zone       = var.az1
  map_public_ip_on_launch = true
}

module "public_subnet_az2" {
  source = "./modules/subnet"

  vpc_id                  = module.vpc.vpc_id
  subnet_cidr             = "10.0.1.0/24"
  subnet_name             = "public_subnet_two"
  availability_zone       = var.az2
  map_public_ip_on_launch = true
}

module "public_subnet_az3" {
  source = "./modules/subnet"

  vpc_id                  = module.vpc.vpc_id
  subnet_cidr             = "10.0.2.0/24"
  subnet_name             = "public_subnet_three"
  availability_zone       = var.az3
  map_public_ip_on_launch = true
}

module "private_subnet_az1" {
  source = "./modules/subnet"

  vpc_id                  = module.vpc.vpc_id
  subnet_cidr             = "10.0.3.0/24"
  subnet_name             = "private_subnet_one"
  availability_zone       = var.az1
  map_public_ip_on_launch = false
}

// Nat gateways
module "nat_gateway" {
  source = "./modules/nat-gateway"

  name      = "nat_gateway_subnet_az1"
  subnet_id = module.public_subnet_az1.subnet_id
}

// Route tables
module "public_route_table" {
  source = "./modules/route-table"

  vpc_id                 = module.vpc.vpc_id
  igw_id                 = module.vpc.igw_id
  name                   = "public_route_table"
  destination_cidr_block = "0.0.0.0/0"
  vpc_cidr_block         = var.vpc_cidr
  subnet_ids = [
    module.public_subnet_az1.subnet_id,
    module.public_subnet_az2.subnet_id,
    module.public_subnet_az3.subnet_id
  ]
}

module "private_route_table" {
  source = "./modules/route-table"

  vpc_id                 = module.vpc.vpc_id
  nat_gateway_id         = module.nat_gateway.nat_gateway_id
  name                   = "private_route_table"
  destination_cidr_block = "0.0.0.0/0"
  vpc_cidr_block         = var.vpc_cidr
  subnet_ids = [
    module.private_subnet_az1.subnet_id
  ]
}

// Security groups
module "http_ssh_security_group" {
  source = "./modules/security-group"

  name        = "http_ssh_security_group"
  description = "Security group for HTTP and SSH"
  vpc_id      = module.vpc.vpc_id
  ingress_rules = [
    {
      cidr_ipv4   = "0.0.0.0/0"
      from_port   = 80
      ip_protocol = "tcp"
      to_port     = 80
    },
    {
      cidr_ipv4   = "0.0.0.0/0"
      from_port   = 22
      ip_protocol = "tcp"
      to_port     = 22
    }
  ]
  egress_rules = [
    {
      cidr_ipv4   = "0.0.0.0/0"
      ip_protocol = "-1"
    }
  ]
}

module "ssh_security_group" {
  source = "./modules/security-group"

  name        = "ssh_security_group"
  description = "Security group for SSH"
  vpc_id      = module.vpc.vpc_id
  ingress_rules = [
    # {
    #     cidr_ipv4     = "0.0.0.0/0"
    #     from_port     = 80
    #     ip_protocol   = "tcp"
    #     to_port       = 80
    # },
    {
      cidr_ipv4   = "0.0.0.0/0"
      from_port   = 22
      ip_protocol = "tcp"
      to_port     = 22
    }
  ]
  egress_rules = [
    {
      cidr_ipv4   = "0.0.0.0/0"
      ip_protocol = "-1"
    }
  ]
}

// Launch templates
module "auth_service_launch_template" {
  source = "./modules/launch-templates"

  ami_id             = var.ubuntu_ami_id
  instance_type      = terraform.workspace == "dev" ? var.dev_instance_type : var.prod_instance_type
  security_group_ids = [module.http_ssh_security_group.security_group_id]
  user_data          = base64encode(file("user_data/auth_service_user_data.sh"))
  template_name      = "auth-service-launch-template"
}

module "main_service_launch_template" {
  source = "./modules/launch-templates"

  ami_id             = var.ubuntu_ami_id
  instance_type      = terraform.workspace == "dev" ? var.dev_instance_type : var.prod_instance_type
  security_group_ids = [module.http_ssh_security_group.security_group_id]
  user_data          = base64encode(file("user_data/main_service_user_data.sh"))
  template_name      = "main-service-launch-template"
}

module "notification_service_launch_template" {
  source = "./modules/launch-templates"

  ami_id             = var.ubuntu_ami_id
  instance_type      = terraform.workspace == "dev" ? var.dev_instance_type : var.prod_instance_type
  security_group_ids = [module.http_ssh_security_group.security_group_id]
  user_data          = base64encode(file("user_data/notification_service_user_data.sh"))
  template_name      = "notification-service-launch-template"
}

// Target groups
module "auth_service_target_group" {
  source = "./modules/target-group"

  vpc_id                         = module.vpc.vpc_id
  target_group_name              = terraform.workspace == "dev" ? "dev-auth-service-target-group" : "prod-auth-service-target-group"
  target_group_port              = 80
  target_group_protocol          = "HTTP"
  target_group_health_check_path = "/"
}

module "main_service_target_group" {
  source = "./modules/target-group"

  vpc_id                         = module.vpc.vpc_id
  target_group_name              = terraform.workspace == "dev" ? "dev-main-service-target-group" : "prod-main-service-target-group"
  target_group_port              = 80
  target_group_protocol          = "HTTP"
  target_group_health_check_path = "/"
}

module "notification_service_target_group" {
  source = "./modules/target-group"

  vpc_id                         = module.vpc.vpc_id
  target_group_name              = terraform.workspace == "dev" ? "dev-notif-service-target-group" : "prod-notif-service-target-group"
  target_group_port              = 80
  target_group_protocol          = "HTTP"
  target_group_health_check_path = "/"
}

// Auto scaling groups
module "auth_service_auto_scaling_group" {
  source = "./modules/auto_scaling_group"

  asg_name           = terraform.workspace == "dev" ? "dev-auth-service-auto-scaling-group" : "prod-auth-service-auto-scaling-group"
  max_size           = 5
  min_size           = 2
  desired_capacity   = 3
  launch_template_id = module.auth_service_launch_template.launch_template_id
  subnet_ids = [
    module.public_subnet_az1.subnet_id,
    module.public_subnet_az2.subnet_id,
    module.public_subnet_az3.subnet_id
  ]
  instance_tag_name = terraform.workspace == "dev" ? "dev-auth-service-instance" : "prod-auth-service-instance"
  target_group_arn  = module.auth_service_target_group.target_group_arn

  depends_on = [module.auth_service_launch_template, module.auth_service_target_group]
}

module "main_service_auto_scaling_group" {
  source = "./modules/auto_scaling_group"

  asg_name           = terraform.workspace == "dev" ? "dev-main-service-auto-scaling-group" : "prod-main-service-auto-scaling-group"
  max_size           = 5
  min_size           = 2
  desired_capacity   = 3
  launch_template_id = module.main_service_launch_template.launch_template_id
  subnet_ids = [
    module.public_subnet_az1.subnet_id,
    module.public_subnet_az2.subnet_id,
    module.public_subnet_az3.subnet_id
  ]
  instance_tag_name = terraform.workspace == "dev" ? "dev-main-service-instance" : "prod-main-service-instance"
  target_group_arn  = module.main_service_target_group.target_group_arn

  depends_on = [module.main_service_launch_template, module.main_service_target_group]
}

module "notification_service_auto_scaling_group" {
  source = "./modules/auto_scaling_group"

  asg_name           = terraform.workspace == "dev" ? "dev-notification-service-auto-scaling-group" : "prod-notification-service-auto-scaling-group"
  max_size           = 5
  min_size           = 2
  desired_capacity   = 3
  launch_template_id = module.notification_service_launch_template.launch_template_id
  subnet_ids = [
    module.public_subnet_az1.subnet_id,
    module.public_subnet_az2.subnet_id,
    module.public_subnet_az3.subnet_id
  ]
  instance_tag_name = terraform.workspace == "dev" ? "dev-notification-service-instance" : "prod-notification-service-instance"
  target_group_arn  = module.notification_service_target_group.target_group_arn

  depends_on = [module.notification_service_launch_template, module.notification_service_target_group]
}

// Application load balancers
module "application_load_balancer" {
  source = "./modules/application_load_balancer"

  alb_name           = terraform.workspace == "dev" ? "dev-application-load-balancer" : "prod-application-load-balancer"
  alb_port           = 80
  alb_protocol       = "HTTP"
  security_groups_id = [module.http_ssh_security_group.security_group_id]
  subnet_ids = [
    module.public_subnet_az1.subnet_id,
    module.public_subnet_az2.subnet_id,
    module.public_subnet_az3.subnet_id
  ]
  routes = [
    {
      path             = "/api/auth*"
      target_group_arn = module.auth_service_target_group.target_group_arn
    },
    {
      path             = "/api/main*"
      target_group_arn = module.main_service_target_group.target_group_arn
    },
    {
      path             = "/api/notification*"
      target_group_arn = module.notification_service_target_group.target_group_arn
    }
  ]

  depends_on = [module.auth_service_auto_scaling_group, module.main_service_auto_scaling_group, module.notification_service_auto_scaling_group]
}

module "ec2_role" {
  source = "./modules/iam-role"

  name = "ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
  policy_arns = [var.ssm_policy_arn]
}

module "instance_profile" {
  source = "./modules/instance-profile"

  name      = "ec2-profile"
  role_name = module.ec2_role.role_name
}

module "web_server_in_private_subnet" {
  source = "./modules/ec2"

  ami                  = var.ubuntu_ami_id
  instance_type        = var.dev_instance_type
  subnet_id            = module.private_subnet_az1.subnet_id
  key_name             = var.ec2_key_name
  security_group_ids   = [module.http_ssh_security_group.security_group_id]
  iam_instance_profile = module.instance_profile.instance_profile_name
  name                 = "vault-server"

  // Enable ssm agent.
  user_data = <<-EOF
              #!/bin/bash
              set -e

              systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service
              systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service
              EOF   
}

