output "vpc_id" {
  value       = aws_vpc.myvpc.id
  description = "The ID of the VPC"
}

output "public_sub1_id" {
  value       = aws_subnet.sub1.id
  description = "The ID of public subnet one"
}

output "public_sub2_id" {
  value       = aws_subnet.sub2.id
  description = "The ID of public subnet two"
}

output "igw_id" {
  value       = aws_internet_gateway.igw.id
  description = "The ID of the internet gateway"
}

output "public_route_table_id" {
  value       = aws_route_table.public_route_table
  description = "The ID of the public route table"
}

output "alb_dns_name" {
  value       = aws_lb.myalb.dns_name
  description = "The DNS name of the Application Load Balancer"
}