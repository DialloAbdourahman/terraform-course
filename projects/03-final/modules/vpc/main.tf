resource "aws_vpc" "this" {
    cidr_block = var.vpc_cidr
    
    tags = {
        Name = var.vpc_name
    }
}

resource "aws_internet_gateway" "this" {
    vpc_id = aws_vpc.this.id
    count = var.add_igw ? 1 : 0
    
    tags = {
        Name = "${var.vpc_name}-igw"
    }
}