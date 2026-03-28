variable "template_name" {
  description = "Name of the launch template"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the launch template"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the launch template"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "user_data" {
  description = "User data script for the launch template"
  type        = string
}

variable "associate_public_ip_address" {
  description = "Whether to associate a public IP address"
  type        = bool
  default     = true
}

variable "tag_name" {
  description = "Name tag for instances launched from this template"
  type        = string
  default     = "app-instance"
}