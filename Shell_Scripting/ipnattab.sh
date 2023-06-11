#!bin/bash

read -p "Enter the name of interface of static net :- " net
echo "auto $net" >> /etc/network/interfaces
echo "iface $net inet static" >> /etc/network/interfaces
echo "address 192.168.1.1/24" >> /etc/network/interfaces
ifup $net
sed -i "28cnet.ipv4.ip_forward=1" /etc/sysctl.conf
sysctl -p
iptables --version &> /dev/null
iptabval= echo $? &> /dev/null
if [[ $iptabval != "0" ]]; then
	apt-get install iptables -y
fi
iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -o ens33 -j MASQUERADE
iptables -t nat -L -v -n
nmsrv= $(cat /etc/resolv.conf | grep nameserver )
echo "Use this ip $nmsrv as dns-nameservers"
read -p "enter ip of remote system :- " ipadd
ssh root\@$ipadd 'bash -s' << 'ENDSSH'
#These all commands running on remote machine
sed -i "12ciface ens33 inet static" /etc/network/interfaces 
echo "address 192.168.1.3/24" >> /etc/network/interfaces
echo "gateway 192.168.1.1" >> /etc/network/interfaces
echo "dns-nameservers 192.168.157.2" >> /etc/network/interfaces
echo "ip route 192.168.1.1" >> /etc/network/interfaces
echo "Please change VMnat as Nat server ,ifdown ens33 and ifup ens33 and host www.google.com"
ENDSSH
sleep 1.5m
ssh root\@192.168.1.3 'bash -s' << 'APACHE'
apt-get install apache2 -y
apt-get install curl -y
echo "192.168.1.3 www.cdac.local" >> /etc/hosts/
APACHE

iptables -t nat -A PREROUTING -i ens33 -p tcp --dport 8080 -j DNAT --to-destination "192.168.1.3:80"
iptables -A FORWARD -i eth0 -p tcp --dport 80 -d 192.168.1.3 -j ACCEPT
iptables -t nat -A POSTROUTING -o ens33 -s 192.168.1.3 -j MASQUERADE


sudo iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j DNAT --to-destination 10.0.0.1
sudo iptables -t nat -A POSTROUTING -o eth1 -p tcp --dport 80 -d 10.0.0.1 -j SNAT --to-source 10.0.0.2