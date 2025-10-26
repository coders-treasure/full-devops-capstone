terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"] 
  filter { name = "name" values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"] }
  filter { name = "virtualization-type" values = ["hvm"] }
}

resource "aws_security_group" "app_sg" {
  name        = "capstone-flask-sg"
  ingress { from_port = 22; to_port = 22; protocol = "tcp"; cidr_blocks = ["0.0.0.0/0"] }
  ingress { from_port = 80; to_port = 80; protocol = "tcp"; cidr_blocks = ["0.0.0.0/0"] }
  egress { from_port = 0; to_port = 0; protocol = "-1"; cidr_blocks = ["0.0.0.0/0"] }
}

resource "aws_instance" "app_server" {
  ami           = data.aws_ami.ubuntu.id 
  instance_type = var.instance_type 
  security_groups = [aws_security_group.app_sg.name] 
  key_name      = var.key_name 
  tags = { Name = "Capstone-Server" }
}

output "server_public_ip" {
  value = aws_instance.app_server.public_ip
}