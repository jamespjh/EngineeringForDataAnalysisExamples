# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair

resource "aws_key_pair" "dev_keypair" {
  key_name   = "ucgajhe_aws_dev_keypair"
  public_key = file("/Users/jamespjh/.ssh/id_rsa.pub")
}