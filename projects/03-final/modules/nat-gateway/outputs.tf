output "nat_gateway_id" {
  value = aws_nat_gateway.this.id
}

output "elastic_ip_id" {
  value = aws_eip.this.id
}