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

output "private_sub3_id" {
  value       = aws_subnet.sub3.id
  description = "The ID of private subnet three"
}

output "igw_id" {
  value       = aws_internet_gateway.igw.id
  description = "The ID of the internet gateway"
}

output "public_route_table_id" {
  value       = aws_route_table.public_route_table
  description = "The ID of the public route table"
}

output "private_route_table_id" {
  value       = aws_route_table.private_route_table
  description = "The ID of the private route table"
}

output "web_server_1_public_ip" {
  value       = aws_instance.web_server_1.public_ip
  description = "Public IPv4 address of Web Server 1"
}

output "web_server_1_public_dns" {
  value       = aws_instance.web_server_1.public_dns
  description = "Public DNS name of Web Server 1"
}

output "web_server_2_public_ip" {
  value       = aws_instance.web_server_2.public_ip
  description = "Public IPv4 address of Web Server 2"
}

output "web_server_2_public_dns" {
  value       = aws_instance.web_server_2.public_dns
  description = "Public DNS name of Web Server 2"
}

output "alb_dns_name" {
  value       = aws_lb.myalb.dns_name
  description = "The DNS name of the Application Load Balancer"
}