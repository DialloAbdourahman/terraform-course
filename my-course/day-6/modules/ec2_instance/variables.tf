variable "region" {
  description = "The region to use for the EC2 instance"
  type        = string
}

variable "ami_value" {
  description = "The AMI ID to use for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "The instance type to use for the EC2 instance"
  type        = string
}

variable "ec2_tag_name" {
  description = "The tag name to use for the EC2 instance"
  type        = string
}