provider "aws" {
  region = "eu-north-1"
}

resource "aws_instance" "first-instance-in-terraform" {
  ami           = "ami-0974a2c5ddf10f442" 
  instance_type = "t3.micro"
  subnet_id     = "subnet-06321d25300654df3"
  key_name      = "ec2-tutorial"
  tags = {
    Name = "first-instance-in-terraform"
  }
}

//////////////////////
// Terraform lifecycle
//////////////////////

// terraform init
// terraform plan
// terraform apply
// terraform destroy
