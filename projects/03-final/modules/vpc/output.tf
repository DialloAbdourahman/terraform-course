output "vpc_id" {
  value       = aws_vpc.this.id
  description = "The ID of the vpc"
}

output "igw_id" {
  # value       = length(aws_internet_gateway.this) > 0 ? aws_internet_gateway.this[0].id : null
  // OR
  value       = var.add_igw ? aws_internet_gateway.this[0].id : null
  description = "The ID of the internet gateway"
}
