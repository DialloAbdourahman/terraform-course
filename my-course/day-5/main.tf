provider "aws" {
  region = "eu-north-1"
}

variable "cidr" {
  default = "10.0.0.0/16"
}

resource "aws_key_pair" "example" {
  key_name   = "diallo-demo-terra-key"  
  public_key = file("~/.ssh/id_rsa.pub") 
}

resource "aws_vpc" "myvpc" {
  cidr_block = var.cidr
}

resource "aws_subnet" "sub1" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "eu-north-1a"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
}

resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.RT.id
}

resource "aws_security_group" "webSg" {
  name   = "web"
  vpc_id = aws_vpc.myvpc.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Web-sg"
  }
}

resource "aws_instance" "server" {
  ami                    = "ami-0974a2c5ddf10f442"
  instance_type          = "t3.micro"
  key_name      = aws_key_pair.example.key_name
  vpc_security_group_ids = [aws_security_group.webSg.id]
  subnet_id              = aws_subnet.sub1.id

  // Telling terraform how to connect to the instance it has created.
  // Here, terraform will use our private key (in our personal computer) to connect to the instance.
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/id_rsa")
    // Since we are already in the ec2 instance block, we can just use the self key word
    host        = self.public_ip
  }

  # File provisioner to copy a file from local to the remote EC2 instance
  provisioner "file" {
    source      = "app.js" // File we are copying
    destination = "/home/ubuntu/app.js" // Destination on the remote instance
  }

  provisioner "remote-exec" {
    inline = [
        "sleep 30",
        "echo 'Hello from the remote instance'",
        "sudo apt-get update -y",
        "sudo apt-get install -y nodejs npm",

        "rm -rf /home/ubuntu/project",
        "mkdir -p /home/ubuntu/project",
        "mv /home/ubuntu/app.js /home/ubuntu/project/app.js",
        "sudo nohup node /home/ubuntu/project/app.js > /home/ubuntu/project/app.log 2>&1 &",
        // Just login manually and run sudo node app.js
    ]
  }

  tags = {
    Name = "Web-server"
  }
}

// When we create a normal key on aws and attach it to an ec2, we need to download the pem key file in order for us to be able to ssh into the ec2 instance.

// When we use terraform to create the key and attach it to an ec2 instance, we are asking terraform to upload our public idrsa file on the ec2 instance so that we can use our computer's secret key to communicate with the remote ec2 instance. This means our computer has our private key and the ec2 instance has our public so which makes communication aka ssh possible. It is the same logic as uploading our idrsa public key to github/gitlab and then using our private key to communicate with the remote server (through ssh).

// Terraform will add the public key in the ec2 instance on this location:  ~/.ssh/authorized_keys.

// I can also now login using my own ssh found in my personal computer using the command (just like what terraform is doing behind the scenes) ssh -i ~/.ssh/id_rsa ubuntu@<public-ip>

// Other devs cannot SSH unless their public key is also added.

