#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
resource "aws_instance" "example_instance" {
  ami                         = "ami-0f9bfd7d2738e70d5"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  key_name                    = aws_key_pair.dev_keypair.key_name
  vpc_security_group_ids      = [aws_security_group.course_group_terraform.id]
  subnet_id                   = data.aws_subnets.selected.ids[0]

  tags = {
    Name   = "ucgajhe-tf-t2micro-instance"
    Method = "Terraform"
    Owner  = "ucgajhe"
    Type   = "exemplar"
  }
}

resource "aws_ebs_volume" "datastoraget2" {
  availability_zone = "eu-west-2a"
  size              = 128 #GiB
  type              = "gp3"
  tags = {
    Owner  = "ucgajhe"
    Type   = "exemplar"
    Method = "Terraform"
  }
}

resource "aws_volume_attachment" "t2-attach" {
  device_name = "/dev/xvdf"
  volume_id   = aws_ebs_volume.datastoraget2.id
  instance_id = aws_instance.example_instance.id
}