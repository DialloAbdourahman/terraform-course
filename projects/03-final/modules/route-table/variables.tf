variable "vpc_id" {
  type = string
}

variable "igw_id" {
  type = string
  default = ""
}

variable "name" {
  type = string
}

variable "destination_cidr_block" {
  type = string
}

variable "nat_gateway_id" {
  type = string
  default = ""
}

variable "vpc_cidr_block" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}