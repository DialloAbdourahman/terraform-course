output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_igw_id" {
  value = module.vpc.igw_id
}

output "public_subnet_in_az1_id" {
  value = module.public_subnet_az1.subnet_id
}

output "public_subnet_in_az2_id" {
  value = module.public_subnet_az2.subnet_id
}

output "public_subnet_in_az3_id" {
  value = module.public_subnet_az3.subnet_id
}

output "private_subnet_az1_id" {
  value = module.private_subnet_az1.subnet_id
}

output "public_route_table_id" {
  value = module.public_route_table.route_table_id
}

output "private_route_table_id" {
  value = module.private_route_table.route_table_id
}

output "http_ssh_security_group_id" {
  value = module.http_ssh_security_group.security_group_id
}

output "auth_service_launch_template" {
  value = module.auth_service_launch_template.launch_template_id
}

output "auth_service_target_group_arn" {
  value = module.auth_service_target_group.target_group_arn
}

output "auth_service_auto_scaling_group_id" {
  value = module.auth_service_auto_scaling_group.asg_id
}

output "main_service_launch_template" {
  value = module.main_service_launch_template.launch_template_id
}

output "main_service_target_group_arn" {
  value = module.main_service_target_group.target_group_arn
}

output "main_service_auto_scaling_group_id" {
  value = module.main_service_auto_scaling_group.asg_id
}

output "notification_service_launch_template" {
  value = module.notification_service_launch_template.launch_template_id
}

output "notification_service_target_group_arn" {
  value = module.notification_service_target_group.target_group_arn
}

output "notification_service_auto_scaling_group_id" {
  value = module.notification_service_auto_scaling_group.asg_id
}

output "application_load_balancer_dns_name" {
  value = module.application_load_balancer.alb_dns_name
}

output "iam_role_name" {
  value = module.ec2_role.role_name
}

output "instance_profile_name" {
  value = module.instance_profile.instance_profile_name
}
