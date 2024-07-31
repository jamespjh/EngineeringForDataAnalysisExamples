#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
resource "aws_instance" "example_instances" {
  for_each                    = toset(["t2.micro", "c4.2xlarge"])
  ami                         = "ami-0f0331fe42823e748"
  instance_type               = each.key
  associate_public_ip_address = true
  key_name                    = aws_key_pair.dev_keypair.key_name
  vpc_security_group_ids      = [aws_security_group.course_group_terraform.id]
  subnet_id                   = data.aws_subnets.selected.ids[0]
  #  https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html
  user_data                   = templatefile("${path.module}/init_exemplar.sh", { message = "Hello World!" })
  user_data_replace_on_change = true

  tags = {
    Name   = "ucgajhe-tf-${each.key}-instance"
    Method = "Terraform"
    Owner  = "ucgajhe"
    Type   = "exemplar"
  }
}

resource "aws_ebs_volume" "datastorage" {
  for_each          = aws_instance.example_instances
  availability_zone = "eu-west-2a"
  size              = 128 #GiB
  type              = "gp3"
  tags = {
    Owner  = "ucgajhe"
    Type   = "exemplar"
    Method = "Terraform"
    Name   = "ucgajhe-tf-${each.key}-instance"
  }
}

resource "aws_volume_attachment" "t2-attach" {
  for_each    = aws_instance.example_instances
  device_name = "/dev/xvdf"
  volume_id   = aws_ebs_volume.datastorage[each.key].id
  instance_id = aws_instance.example_instances[each.key].id
}