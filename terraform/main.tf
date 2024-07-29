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

resource "aws_instance" "example_instance" {
  ami                         = "ami-0f9bfd7d2738e70d5"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  key_name                    = "ucgajhe_aws_dev_keypair"

  tags = {
    Name  = "TerraformInstance"
    Owner = "ucgajhe"
    Type  = "exemplar"
  }
}