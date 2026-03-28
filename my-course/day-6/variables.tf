variable "region" {
  description = "The region to use for the EC2 instance"
  type        = string
}

variable "ami_value" {
  description = "The AMI ID to use for the EC2 instance"
  type        = string
}

variable "dev_instance_type" {
  description = "The instance type to use for the EC2 instance in dev environment"
  type        = string
}

variable "prod_instance_type" {
  description = "The instance type to use for the EC2 instance in prod environment"
  type        = string
}

variable "ec2_tag_name" {
  description = "The tag name to use for the EC2 instance"
  type        = map(string)

  default = {
    dev = "dev-web-server"
    prod = "prod-web-server"
  }
}

