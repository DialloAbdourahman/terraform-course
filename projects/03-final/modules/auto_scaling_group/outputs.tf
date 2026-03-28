output "asg_id" {
  description = "ID of the auto scaling group"
  value       = aws_autoscaling_group.app_asg.id
}