variable "awsprops" {
    type = map
    default = {
    region = "us-east-1"
    vpc = "vpc-024352cd520f606bb"
    ami = "ami-007855ac798b5175e"
    itype = "t2.micro"
    subnet = "subnet-0ebfbe19238f99c3f"
    publicip = true
    keyname = "ec2-tute"
    secgroupname = "IAC-Secur-Group"
  }
}

provider "aws" {
  region = lookup(var.awsprops, "region")
}

resource "aws_security_group" "project-iac-sg" {
  name = lookup(var.awsprops, "secgroupname")
  description = lookup(var.awsprops, "secgroupname")
  vpc_id = lookup(var.awsprops, "vpc")

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


resource "aws_instance" "project-iac" {
  ami = lookup(var.awsprops, "ami")
  instance_type = lookup(var.awsprops, "itype")
  subnet_id = lookup(var.awsprops, "subnet") #FFXsubnet2
  associate_public_ip_address = lookup(var.awsprops, "publicip")
  key_name = lookup(var.awsprops, "keyname")


  vpc_security_group_ids = [
    aws_security_group.project-iac-sg.id
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

  depends_on = [ aws_security_group.project-iac-sg ]
}


output "ec2instance" {
  value = aws_instance.project-iac.public_ip
}