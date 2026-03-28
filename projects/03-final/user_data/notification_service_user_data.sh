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

# Create the API directory structure
mkdir -p /var/www/html/api/notification

# Create content for the notification service
echo "<h1>Notification Service API - $(hostname -f)</h1>" | tee /var/www/html/api/notification/index.html