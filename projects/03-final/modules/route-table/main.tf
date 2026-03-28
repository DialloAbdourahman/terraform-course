resource "aws_route_table" "this" {
  vpc_id = var.vpc_id

  route {
    cidr_block = var.destination_cidr_block
    gateway_id = var.igw_id != "" ? var.igw_id : null
    nat_gateway_id = var.nat_gateway_id != "" ? var.nat_gateway_id : null
  }

  route {
    cidr_block = var.vpc_cidr_block
    gateway_id = "local"
  }

  tags = {
    Name = "${var.name}-route-table"
  }
}

resource "aws_route_table_association" "this" {
  count = length(var.subnet_ids)
  
  // We are iterating over the subnet_ids list and associating each subnet with the route table
  subnet_id      = var.subnet_ids[count.index]
  route_table_id = aws_route_table.this.id
}