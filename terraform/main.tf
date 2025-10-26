# --- 1. CONFIGURATION AND PROVIDER SETUP ---
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

# --- 2. DATA SOURCE: DYNAMIC AMI FINDER ---
data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"]
  filter { 
    name = "name" 
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"] 
  }
  filter { 
    name = "virtualization-type" 
    values = ["hvm"] 
  }
}

# --- 3. RESOURCE: SECURITY GROUP (FIREWALL) ---
resource "aws_security_group" "app_sg" {
  name        = "capstone-flask-sg"
  description = "Security Group for Flask application server"
  
  # Allow SSH (Port 22) for management
  ingress { 
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }
  
  # Allow HTTP (Port 80) for the public web app access
  ingress { 
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }
  
  # Allow all outbound traffic
  egress { 
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] 
  }
}

# --- 4. RESOURCE: EC2 INSTANCE (THE SERVER) ---
resource "aws_instance" "app_server" {
  ami           = data.aws_ami.ubuntu.id 
  instance_type = var.instance_type 
  security_groups = [aws_security_group.app_sg.name] 
  key_name      = var.key_name 
  tags = { Name = "Capstone-Server" }
}

# --- 5. OUTPUTS ---
output "server_public_ip" {
  description = "The public IP address of the Capstone-Server"
  value       = aws_instance.app_server.public_ip
}