// Create target group for ALB
resource "aws_lb_target_group" "this" {
  name     = var.target_group_name
  port     = var.target_group_port
  protocol = var.target_group_protocol
  vpc_id   = var.vpc_id

  health_check {
    // Since our instances are running in the /
    path = var.target_group_health_check_path
    port = "traffic-port"
  }
}