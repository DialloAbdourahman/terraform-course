provider "aws" {
  region = var.region
}

resource "aws_instance" "web_server" {
  ami           = var.ami_value
  instance_type = var.instance_type
  
  tags = {
    Name = var.ec2_tag_name
  }
}
