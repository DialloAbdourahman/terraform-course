resource "aws_instance" "my_ec2" {
  ami           = var.ami_value
  instance_type = var.instance_type
}
