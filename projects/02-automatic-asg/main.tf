// Create VPC
resource "aws_vpc" "myvpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "myvpc"
  }
}

// Create subnet one (public)
resource "aws_subnet" "sub1" {
  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = var.sub1_cidr
  availability_zone = var.availability_zone_1

  // Automatically assign public IP to instances in this subnet.
  map_public_ip_on_launch = true

  tags = {
    Name = "Public subnet one"
  }
}

// Create subnet two (public)
resource "aws_subnet" "sub2" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = var.sub2_cidr
  availability_zone       = var.availability_zone_2
  map_public_ip_on_launch = true

  tags = {
    Name = "Public subnet two"
  }
}

// Create internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "Internet gateway"
  }
}

// Create public route table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public route table"
  }
}

// Attaching the public route table to the first subnet
resource "aws_route_table_association" "sub1_rta" {
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.public_route_table.id
}

// Attaching the public route table to the second subnet
resource "aws_route_table_association" "sub2_rta" {
  subnet_id      = aws_subnet.sub2.id
  route_table_id = aws_route_table.public_route_table.id
}

// Create SG
resource "aws_security_group" "http_ssh_sg" {
  name        = "http_ssh_sg"
  description = "Allow HTTP and SSH inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.myvpc.id

  tags = {
    Name = "http_ssh_sg"
  }
}

// Open port 22 for SSH
resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.http_ssh_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

// Open port 80 for http 
resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.http_ssh_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

// Allow all outbound traffic
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.http_ssh_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

// Create iam role for ec2
resource "aws_iam_role" "ec2_role" {
  name = "ec2-role"

  // Who is allowed to assume role (trusted policy)
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        // This role will be attached to an ec2 instance.
        Service = "ec2.amazonaws.com"
      }
      // STS (security token service gives me temporary credentials to assume this role.)
      Action = "sts:AssumeRole"
    }]
  })
}

// Add session manager to role.
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = var.ssm_policy_arn
}

// Create profile from the role we created above.
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-profile"
  role = aws_iam_role.ec2_role.name
}

// Create target group for ALB
resource "aws_lb_target_group" "alb_tg" {
  name     = "alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myvpc.id

  health_check {
    // Since our instances are running in the /
    path = "/"
    port = "traffic-port"
  }
}

resource "aws_launch_template" "app" {
  name_prefix   = "app-template-"
  image_id      = var.ubuntu_ami          # AMI
  instance_type = var.ec2_instance_type
  key_name      = var.ec2_key_name

  # IAM role (must be set via instance profile)
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  # Network interfaces
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.http_ssh_sg.id]
  }

  # User data (bootstrap script)
  user_data = base64encode(file("userdata.sh"))

  # Tags for instances launched from this template
  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "app-instance"
    }
  }
}

// Create ALB
resource "aws_lb" "myalb" {
  name               = "myalb"
  internal           = false
  load_balancer_type = "application"
  // Here, we can create another SG with port 80 open just for the ALB
  security_groups = [aws_security_group.http_ssh_sg.id]
  subnets         = [aws_subnet.sub1.id, aws_subnet.sub2.id]

  tags = {
    Name = "My ALB"
  }
}

// Add the listener (attach TG to ALB)
resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.myalb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
}

# Create ASG
resource "aws_autoscaling_group" "app_asg" {
  name                 = "app-asg"
  max_size             = 4
  min_size             = 1
  desired_capacity     = 2

  # Use your launch template
  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"   # Always use the latest version of your launch template
  }

  # Subnets where the ASG should launch instances
  vpc_zone_identifier = [aws_subnet.sub1.id, aws_subnet.sub2.id]

  # Connect to your ALB target group (optional but recommended)
  target_group_arns = [aws_lb_target_group.alb_tg.arn]

  # Tag instances automatically
  tag {
    key                 = "Name"
    value               = "app-instance"
    propagate_at_launch = true
  }

  # Optional: enable metrics and health checks
  health_check_type         = "EC2"  # Or "ELB" to check through ALB
  health_check_grace_period = 120    # Seconds

  # Optional: protect new instances from accidental termination
  force_delete = true  # Set to true if you want to allow Terraform to delete the ASG along with instances
}






















