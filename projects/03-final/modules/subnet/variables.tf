variable "vpc_id" {
  type = string
}

variable "subnet_cidr" {
  type = string
}

variable "subnet_name" {
  type = string
}

variable "availability_zone" {
  type = string
}

variable "map_public_ip_on_launch" {
  type = bool
  default = false
}