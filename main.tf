terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4"
    }
  }
 required_version = ">= 1.0"
}


provider "aws" {

  region = "eu-west-1"

}

resource "aws_instance" "epam_ec2_instance" {

  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  depends_on             = [ aws_db_instance.epam-rds ]
  user_data = <<EOF
#!/bin/bash
sudo yum update -y
sudo amazon-linux-extras install nginx1 -y
echo "<h1>It's Work!</h1>"| sudo tee /usr/share/nginx/html/index.html
sudo systemctl start nginx
sudo systemctl enable nginx
EOF
   tags = {
      "Name" = "epam_ec2_nginx"
    }
}
data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
    }
  owners = ["amazon"]
}


resource "aws_db_instance" "epam-rds" {
  identifier = "epam-database"
  allocated_storage    = 20
  storage_type = "gp2"
  engine               = "postgres"
  engine_version       = "13"
  instance_class       = var.instance_class
  port                 = var.db_port
  db_name              = var.database
  username             = var.db_user
  password             = var.db_password
  parameter_group_name = "default.postgres13"
  skip_final_snapshot  = true


  tags = {
      Name = "epam_rds_database"
  }
}