variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "sub1_cidr" {
  description = "The CIDR block for subnet one"
  type        = string
  default     = "10.0.0.0/24"
}

variable "sub2_cidr" {
  description = "The CIDR block for subnet two"
  type        = string
  default     = "10.0.1.0/24"
}

variable "sub3_cidr" {
  description = "The CIDR block for subnet three"
  type        = string
  default     = "10.0.2.0/24"
}

variable "availability_zone_1" {
  description = "The first availability zone"
  type        = string
  default     = "eu-north-1a"
}

variable "availability_zone_2" {
  description = "The second availability zone"
  type        = string
  default     = "eu-north-1b"
}

variable "availability_zone_3" {
  description = "The third availability zone"
  type        = string
  default     = "eu-north-1c"
}

variable "ubuntu_ami" {
  description = "The Ubuntu AMI to use"
  type        = string
  default     = "ami-0974a2c5ddf10f442"
}

variable "ec2_key_name" {
  description = "The EC2 key pair name to use"
  type        = string
  default     = "ec2-tutorial"
}

variable "ec2_instance_type" {
  description = "The EC2 instance type to use"
  type        = string
  default     = "t3.micro"
}

variable "ssm_policy_arn" {
  description = "The SSM policy ARN to attach to the EC2 role"
  type        = string
  default     = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
