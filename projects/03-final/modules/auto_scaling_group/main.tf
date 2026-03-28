resource "aws_autoscaling_group" "app_asg" {
  name                 = var.asg_name
  max_size             = var.max_size
  min_size             = var.min_size
  desired_capacity     = var.desired_capacity

  # Use your launch template
  launch_template {
    id      = var.launch_template_id
    version = "$Latest"   # Always use the latest version of your launch template
  }

  # Subnets where the ASG should launch instances
  vpc_zone_identifier = var.subnet_ids

  # Connect to your ALB target group (optional but recommended)
  target_group_arns = [var.target_group_arn]

  # Tag instances automatically
  tag {
    key                 = "Name"
    value               = var.instance_tag_name
    propagate_at_launch = true
  }

  # Optional: enable metrics and health checks
  health_check_type         = "EC2"  # Or "ELB" to check through ALB
  health_check_grace_period = 120    # Seconds

  # Optional: protect new instances from accidental termination
  force_delete = true  # Set to true if you want to allow Terraform to delete the ASG along with instances
}