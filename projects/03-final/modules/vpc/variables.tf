variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "Name of the VPC"
  type        = string
}

variable "add_igw" {
  description = "Add internet gateway to the VPC"
  type        = bool
  default     = true
}