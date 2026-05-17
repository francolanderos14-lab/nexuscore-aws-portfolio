#!/bin/bash
exec > /var/log/user-data.log 2>&1

# Actualizar sistema
yum update -y

# Instalar Docker
amazon-linux-extras install docker -y
systemctl enable docker
systemctl start docker
usermod -aG docker ec2-user

# Instalar CloudWatch agent
yum install -y amazon-cloudwatch-agent

# Levantar WordPress
docker run -d \
  --name app \
  --restart unless-stopped \
  -p 8080:80 \
  -e WORDPRESS_DB_HOST="${db_endpoint}" \
  -e WORDPRESS_DB_USER="admin" \
  -e WORDPRESS_DB_PASSWORD="${db_password}" \
  -e WORDPRESS_DB_NAME="wordpressdb" \
  wordpress:latest

echo "NexusCore listo - $(date)" >> /var/log/user-data.log