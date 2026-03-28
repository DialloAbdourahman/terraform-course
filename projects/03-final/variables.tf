variable "aws_region" {
  description = "The region to use for the EC2 instance"
  type        = string
}

variable "dev_vpc_name" {
  description = "Name of the dev VPC"
  type        = string
}

variable "prod_vpc_name" {
  description = "Name of the prod VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "Name of the VPC"
  type        = string
}

variable "az1" {
  description = "Name of the VPC"
  type        = string
}

variable "az2" {
  description = "Name of the VPC"
  type        = string
}

variable "az3" {
  description = "Name of the VPC"
  type        = string
}

variable "ubuntu_ami_id" {
  description = "Ubuntu AMI ID for the EC2 instance"
  type        = string
}

variable "dev_instance_type" {
  description = "Instance type for the dev environment"
  type        = string
}

variable "prod_instance_type" {
  description = "Instance type for the prod environment"
  type        = string
}

variable "ec2_key_name" {
  description = "EC2 key name for the EC2 instances"
  type        = string
}

variable "ssm_policy_arn" {
  description = "The SSM policy ARN to attach to the EC2 role"
  type        = string
}
