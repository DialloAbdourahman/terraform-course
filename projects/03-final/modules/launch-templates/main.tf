resource "aws_launch_template" "app" {
  name_prefix   = var.template_name
  image_id      = var.ami_id
  instance_type = var.instance_type

  # Network interfaces
  network_interfaces {
    associate_public_ip_address = var.associate_public_ip_address
    security_groups             = var.security_group_ids
  }

  user_data = var.user_data

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = var.tag_name
    }
  }
}