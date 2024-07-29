
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

      # - proto: tcp
      #   ports: 80
      #   group_name: cluster_security_group
      #   rule_desc: Allow each element of the cluster to access other machines in the cluster with WWW
      #   # only works via PRIVATE IP
      # - proto: tcp
      #   ports: 22
      #   group_name: cluster_security_group
      #   rule_desc: Allow each element of the cluster to access other machines in the cluster with SSH
