terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "eu-west-2"
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc
data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = ["comp0235-vpc"]
  }
}

#https://registry.terraform.io/providers/hashicorp/aws/3.9.0/docs/data-sources/subnet_ids
data "aws_subnet_ids" "selected" {
  vpc_id = data.aws_vpc.selected.id
  filter {
    name   = "tag:Name"
    values = ["comp0235-subnet-public1-eu-west-2a"]
  }
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "course_group_terraform" {
  name        = "course_group_terraform"
  description = "Rules for the course group"
  vpc_id      = data.aws_vpc.selected.id

  tags = {
    Method = "Terraform"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.course_group_terraform.id
  cidr_ipv4         = "82.129.126.13/32"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.course_group_terraform.id
  cidr_ipv4         = "82.129.126.13/32"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.course_group_terraform.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
  security_group_id = aws_security_group.course_group_terraform.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
resource "aws_instance" "example_instance" {
  ami                         = "ami-0f9bfd7d2738e70d5"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  key_name                    = "ucgajhe_aws_dev_keypair"
  vpc_security_group_ids      = [aws_security_group.course_group_terraform.id]
  subnet_id                   = data.aws_subnet_ids.selected.id

  tags = {
    Name   = "TerraformInstance"
    Method = "Terraform"
    Owner  = "ucgajhe"
    Type   = "exemplar"
  }
}