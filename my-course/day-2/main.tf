provider "aws" {
  region = "eu-north-1"
  alias = "eu_north_1"
}

provider "aws" {
  region = "us-east-1"
  alias = "us_east_1"
}

resource "aws_instance" "instance-in-eu-north-1" {
  ami           = "ami-0974a2c5ddf10f442" 
  instance_type = "t3.micro"
  subnet_id     = "subnet-06321d25300654df3"
  key_name      = "ec2-tutorial"
  tags = {
    Name = "instance-in-eu-north-1"
  }
  provider = aws.eu_north_1
}

resource "aws_instance" "instance-in-us-east-1" {
  ami           = "ami-0b6c6ebed2801a5cb" 
  instance_type = "t3.micro"
  subnet_id     = "subnet-0b4d45b84ef2dcfb5"
#   key_name      = "ec2-tutorial"
  tags = {
    Name = "instance-in-us-east-1"
  }
  provider = aws.us_east_1
}