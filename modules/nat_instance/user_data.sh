#!/bin/bash
set -euxo pipefail

yum update -y

echo 1 > /proc/sys/net/ipv4/ip_forward
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

yum install -y iptables-services
systemctl enable iptables
service iptables save

echo "NexusCore NAT Instance configurada correctamente - $(date)" >> /var/log/nat-setup.log