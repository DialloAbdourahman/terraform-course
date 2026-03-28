resource "aws_security_group" "this" {
  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id

  tags = {
    Name = var.name
  }
}

resource "aws_vpc_security_group_ingress_rule" "this" {
  count = length(var.ingress_rules)

  security_group_id = aws_security_group.this.id
  cidr_ipv4         = var.ingress_rules[count.index].cidr_ipv4
  from_port         = var.ingress_rules[count.index].from_port
  ip_protocol       = var.ingress_rules[count.index].ip_protocol
  to_port           = var.ingress_rules[count.index].to_port
}

resource "aws_vpc_security_group_egress_rule" "this" {
  count = length(var.egress_rules)

  security_group_id = aws_security_group.this.id
  cidr_ipv4         = var.egress_rules[count.index].cidr_ipv4
  ip_protocol       = var.egress_rules[count.index].ip_protocol
}