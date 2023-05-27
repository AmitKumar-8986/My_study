#!bin/bash

apt-get install iptables -y
apt-get install ssh -y
apt-get install apache2 -y
apt-get install curl -y
echo "192.168.157.128 cdac.local" >> /etc/hosts
iptables -P INPUT DROP
iptables -P OUTPUT ACCEPT
iptables -A INPUT -m  conntrack --ctstate ESTABLISHED, RELATED -j ACCEPT
iptables -A INPUT -p tcp -s 192.168.157.130,192.168.157.131 --dport 80 -j ACCEPT
iptables -A INPUT -p tcp -s 192.168.157.130,192.168.157.131 --dport 443 -j ACCEPT
iptables -A INPUT -p tcp -s 192.168.157.131 --dport 22 -j ACCEPT
iptables -A INPUT -j LOG
