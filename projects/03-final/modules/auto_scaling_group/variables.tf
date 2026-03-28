variable "asg_name" {
  description = "Name of the auto scaling group"
  type        = string
}

variable "target_group_arn" {
  description = "ARN of the target group"
  type        = string
}

variable "max_size" {
  description = "Maximum size of the auto scaling group"
  type        = number
}

variable "min_size" {
  description = "Minimum size of the auto scaling group"
  type        = number
}

variable "desired_capacity" {
  description = "Desired capacity of the auto scaling group"
  type        = number
}

variable "launch_template_id" {
  description = "ID of the launch template"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "instance_tag_name" {
  description = "Name of the instance tag"
  type        = string
}