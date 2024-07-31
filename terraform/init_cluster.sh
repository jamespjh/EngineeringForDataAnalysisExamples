#!/bin/bash
mkdir -p /etc/ansible/facts.d
echo """
[cluster]
rank=${rank}
size=${size}
headnode_private_ip=${headnode_private_ip}
""" > /etc/ansible/facts.d/custom.fact
