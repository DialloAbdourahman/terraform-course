#!/bin/bash
apt update
apt install -y apache2

# Install the AWS CLI
apt install -y awscli

# Enable ssm agent
systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent
systemctl start snap.amazon-ssm-agent.amazon-ssm-agent

# Install apache2
systemctl start apache2
systemctl enable apache2
echo "<h1>Hello World from $(hostname -f)</h1>" | tee /var/www/html/index.html