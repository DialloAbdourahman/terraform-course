variable "routes" {
  type = list(object({
    path = string
    target_group_arn = string
  }))
}

variable "alb_name" {
  type = string
}

variable "alb_port" {
  type = number
}

variable "alb_protocol" {
  type = string
}

variable "security_groups_id" {
  type = list(string)
}

variable "subnet_ids" {
  type = list(string)
}

