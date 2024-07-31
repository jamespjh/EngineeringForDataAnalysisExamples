#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
variable "cluster_size" {
  description = "Number of workers to provision."
  type        = number
  default     = 4
}

resource "aws_instance" "headnode" {
  ami                         = "ami-0f0331fe42823e748"
  instance_type               = "c4.2xlarge"
  associate_public_ip_address = true
  key_name                    = aws_key_pair.dev_keypair.key_name
  vpc_security_group_ids      = [aws_security_group.course_group_terraform.id]
  subnet_id                   = data.aws_subnets.selected.ids[0]
  #  https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html
  user_data = templatefile("${path.module}/init_cluster.sh",
  { rank = "Headnode", size = var.cluster_size, headnode_private_ip = "127.0.0.1" })
  user_data_replace_on_change = true

  tags = {
    Name   = "ucgajhe-cluster-headnode"
    Method = "Terraform"
    Owner  = "ucgajhe"
    Type   = "Headnode"
  }
}

resource "aws_ebs_volume" "headnode_storage" {
  availability_zone = "eu-west-2a"
  size              = 128 #GiB
  type              = "gp3"
  tags = {
    Owner  = "ucgajhe"
    Type   = "ClusterStorage"
    Method = "Terraform"
    Name   = "ucgajhe-tf-headnode-data-volume"
  }
}

resource "aws_volume_attachment" "head-attach" {
  device_name = "/dev/xvdf"
  volume_id   = aws_ebs_volume.headnode_storage.id
  instance_id = aws_instance.headnode.id
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
resource "aws_instance" "workers" {
  for_each                    = toset(formatlist("%v", range(var.cluster_size)))
  ami                         = "ami-0f9bfd7d2738e70d5"
  instance_type               = "c4.2xlarge"
  associate_public_ip_address = true
  key_name                    = aws_key_pair.dev_keypair.key_name
  vpc_security_group_ids      = [aws_security_group.course_group_terraform.id]
  subnet_id                   = data.aws_subnets.selected.ids[0]
  #  https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html
  user_data = templatefile("${path.module}/init_cluster.sh",
  { rank = each.key, size = var.cluster_size, headnode_private_ip = aws_instance.headnode.private_ip })
  user_data_replace_on_change = true

  tags = {
    Name   = "cluster-client-${each.key}"
    Method = "Terraform"
    Owner  = "ucgajhe"
    Type   = "Worker"
    Rank   = each.key
    Size   = var.cluster_size
  }
}