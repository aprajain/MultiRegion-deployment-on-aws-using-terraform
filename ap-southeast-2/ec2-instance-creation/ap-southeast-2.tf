variable "awsprops2" {
    type = map
    default = {
    region = "ap-southeast-2"
    vpc = "vpc-0e58bf37f115b4dc0"
    ami = "ami-05f998315cca9bfe3"
    itype = "t2.micro"
    subnet = "subnet-0fd0df13e75df8c1a"
    publicip = true
    keyname = "ec2-apsoutheast"
    secgroupname = "IAC-Sec-Group"
  }
}


provider "aws" {
  region = lookup(var.awsprops2, "region")
}

resource "aws_security_group" "project-sg" {
  name = lookup(var.awsprops2, "secgroupname")
  description = lookup(var.awsprops2, "secgroupname")
  vpc_id = lookup(var.awsprops2, "vpc")

  // To Allow SSH Transport
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  // To Allow Port 80 Transport
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_instance" "project" {
  ami = lookup(var.awsprops2, "ami")
  instance_type = lookup(var.awsprops2, "itype")
  subnet_id = lookup(var.awsprops2, "subnet") #FFXsubnet2
  associate_public_ip_address = lookup(var.awsprops2, "publicip")
  key_name = lookup(var.awsprops2, "keyname")


  vpc_security_group_ids = [
    aws_security_group.project-sg.id
  ]
  user_data = <<EOF
    
  #!/bin/bash -xe
    sudo apt update
    sudo apt install -y ruby-full
    sudo apt install wget
    cd /home/ubuntu
    wget https://aws-codedeploy-us-east-2.s3.us-east-2.amazonaws.com/latest/install
    sudo chmod +x ./install
    sudo ./install auto
    sudo service codedeploy-agent start

    EOF


  root_block_device {
    delete_on_termination = true
    
    volume_size = 50
    volume_type = "gp2"
  }

  iam_instance_profile = "ec2-codedeploy"


  tags = {
    Name ="SERVER01"
    Environment = "DEV"
    OS = "UBUNTU"
    Managed = "IAC"
  }

  depends_on = [ aws_security_group.project-sg ]
}


output "ec2instance" {
  value = aws_instance.project.public_ip
}