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

// Create subnet three (private)
resource "aws_subnet" "sub3" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = var.sub3_cidr
  availability_zone       = var.availability_zone_3
  map_public_ip_on_launch = false

  tags = {
    Name = "Private subnet three"
  }
}


// Create internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "Internet gateway"
  }
}

// Create elastic ip for nat gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "NAT EIP"
  }
}

// Create NAT gateway on public subnet and associate the elastic ip to it.
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.sub1.id

  tags = {
    Name = "main-nat"
  }

  depends_on = [aws_internet_gateway.igw]
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

// Create private route table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "Private route table"
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

// Attaching the private route table to the third subnet
resource "aws_route_table_association" "sub3_rta" {
  subnet_id      = aws_subnet.sub3.id
  route_table_id = aws_route_table.private_route_table.id
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

// Create an s3 bucket
resource "aws_s3_bucket" "mybucket" {
  bucket = "diallo-test-bucket-1234"

  force_destroy = true

  tags = {
    Name = "Our test bucket"
  }
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

// Create IAM policy for S3 write access
resource "aws_iam_policy" "s3_write_policy" {
  name        = "ec2-s3-write-policy"
  description = "Allow EC2 instances to write to S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.mybucket.arn,
          "${aws_s3_bucket.mybucket.arn}/*"
        ]
      }
    ]
  })
}

// Attach S3 write policy to EC2 role
resource "aws_iam_role_policy_attachment" "s3_write" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_write_policy.arn
}

// Create profile from the role we created above.
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-profile"
  role = aws_iam_role.ec2_role.name
}

// Create first ec2 instance in subnet 1 and run userdata.sh
resource "aws_instance" "web_server_1" {
  ami                    = var.ubuntu_ami
  instance_type          = var.ec2_instance_type
  subnet_id              = aws_subnet.sub1.id
  key_name               = var.ec2_key_name
  vpc_security_group_ids = [aws_security_group.http_ssh_sg.id]
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.id

  user_data = base64encode(file("userdata.sh"))
  # user_data_replace_on_change = true

  tags = {
    Name = "Web Server 1"
  }
}

// Create second ec2 instance in subnet 2 and run userdata.sh
resource "aws_instance" "web_server_2" {
  ami                    = var.ubuntu_ami
  instance_type          = var.ec2_instance_type
  subnet_id              = aws_subnet.sub2.id
  key_name               = var.ec2_key_name
  vpc_security_group_ids = [aws_security_group.http_ssh_sg.id]
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.id

  user_data = base64encode(file("userdata.sh"))
  # user_data_replace_on_change = true

  tags = {
    Name = "Web Server 2"
  }
}

// Create third ec2 instance in subnet 3 and run userdata.sh
resource "aws_instance" "web_server_3" {
  ami                    = var.ubuntu_ami
  instance_type          = var.ec2_instance_type
  subnet_id              = aws_subnet.sub3.id
  key_name               = var.ec2_key_name
  vpc_security_group_ids = [aws_security_group.http_ssh_sg.id]
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.id

  // Enable ssm agent.
  user_data = <<-EOF
              #!/bin/bash
              set -e

              systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service
              systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service
              EOF

  tags = {
    Name = "Web Server 3"
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

  access_logs {
    bucket  = aws_s3_bucket.mybucket.id
    prefix  = "alb-logs"
    enabled = true
  }

  tags = {
    Name = "My ALB"
  }
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

// Attach both instances to TG
resource "aws_lb_target_group_attachment" "alb_tg_attachment_1" {
  target_group_arn = aws_lb_target_group.alb_tg.arn
  target_id        = aws_instance.web_server_1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "alb_tg_attachment_2" {
  target_group_arn = aws_lb_target_group.alb_tg.arn
  target_id        = aws_instance.web_server_2.id
  port             = 80
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

// Allow ALB to write to S3 bucket (service principal: aka tells s3 to allow ELB service to write to the bucket)
resource "aws_s3_bucket_policy" "alb_logs_policy" {
  bucket = aws_s3_bucket.mybucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSALBLogsPolicy"
        Effect = "Allow"
        Principal = {
          Service = "logdelivery.elasticloadbalancing.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.mybucket.arn}/alb-logs/*"
      }
    ]
  })
}

// scp -i ec2-tutorial.pem ./ec2-tutorial.pem  ubuntu@13.61.13.22:/home/ubuntu/ (copy file from local to ec2)