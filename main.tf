# 1. Визначаємо провайдера 
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# 2. Налаштування провайдера
provider "aws" {
  region = "eu-north-1"
}

# 3. Security Group 
resource "aws_security_group" "web_sg" {
  name        = "lab6-security-group"
  description = "Allow SSH and HTTP"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 4. Опис ресурсу 
resource "aws_instance" "web_server" {
  ami           = "ami-09a9858973b288bdd" 
  instance_type = "t3.micro"
  key_name      = "keyforlab4"
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name        = "Lab6-Terraform-Instance"
    Environment = "Education"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y docker.io
              sudo systemctl start docker
              sudo docker run -d -p 80:80 valkras/lab5:latest
              EOF
}

# 5. Вивід даних 
output "instance_public_ip" {
  description = "Публічна IP-адреса створеного сервера"
  value       = aws_instance.web_server.public_ip
}
