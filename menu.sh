#!/bin/bash

while true; do
	echo -e "1. Configure DNS\n2. Configure Virtual Web hosting\n3. NFS\n4. Dhcp\n5. VNC\n6. NTP\n7. Squid\n8. Kerberos\n9. Samba\n10. devcot\n11. Exit"
read choice
case $choice in
1)
read -p "Enter An IP Address :- " ip_add
read -p "Enter An Gateway :- " gateway
read -p "Enter a host name to search :- " host
read -p "Enter a hostname for this machine :- " hostname
sudo nmcli connection modify ens33 ipv4.addresses $ip_add/24 ipv4.gateway $gateway ipv4.dns $ip_add,$gateway ipv4.dns-search $host
sudo nmcli general hostname $hostname.$host
sudo systemctl restart NetworkManager
sudo nmcli connection down ens33
sudo nmcli connection up ens33
yum remove bind bind-utils -y
yum install bind bind-utils -y
echo $ip_add > amit
a=`awk -F"." '{print $1}' amit`
b=`awk -F"." '{print $2}' amit`
c=`awk -F"." '{print $3}' amit`
d=`awk -F"." '{print $4}' amit`
sed -i "11c\ listen-on port 53 { $ip_add; };" /etc/named.conf
sed -i '12c\ #listen-on-v6 port 53 { ::1; };' /etc/named.conf
sed -i '19c\allow-query {any;};' /etc/named.conf
echo -e " zone \"$host\" IN { \n\t\ttype master;\n\t\tfile \"for.$host\";\n};" >> /etc/named.conf
echo -e "zone \"$c.$b.$a.in-addr.arpa\" IN{ \n\t\ttype master;\n\t\tfile \"rev.$host\";\n};" >> /etc/named.conf
cd /var/named
echo -e "\$TTL 1D\n@\t\tIN SOA $hostname.$host. email.gmail.com. (0\t1D\t1H\t1W\t3H )\n\t\t\tIN\tNS\t$hostname.$host.\n@\t\tIN\tA\t$ip_add\n$hostname\t\tIN\tA\t$ip_add\nwww\t\tIN\tA\t$ip_add" > for.$host
echo -e "\$TTL 1D\n@\t\tIN SOA $hostname.$host. email.gmail.com. (0\t1D\t1H\t1W\t3H )\n\t\t\tIN\tNS\t$hostname.$host.\n$d\t\tIN\tPTR\t$hostname.$host." > rev.$host
chgrp named for.$host rev.$host
systemctl restart named
systemctl enable named
host -t NS $host
;;
2)
yum install httpd -y
echo "IncludeOptional sites-enabled/*.conf" >> /etc/httpd/conf/httpd.conf
mkdir /etc/httpd/sites-available
mkdir /etc/httpd/sites-enabled
ahost=`hostname | awk -F"." '{print $2"."$3}'`
IP=`ifconfig | egrep -o "[0-9]{1,3}\.[0-9]{0,3}\.[0-9]{0,3}\.[0-9]{1,3}" | grep -v "^127\|^255\|255$"`
read -p "How many sites you want" nsite
for i in `seq $nsite`;do
read -p "Enter website name $i :- " webname
read -p "Enter website Alias name $i :- " webA
echo -e "<VirtualHost *:80>\n\tServerName $webname.$ahost\n\tServerAlias $webA.$ahost\n\tDocumentRoot /var/www/html/$webname/\n\tErrorLog /var/log/httpd/${webname}_errorlog\n\tCustomLog /var/log/httpd/${webname}_Access_log combined\n</VirtualHost>" > /etc/httpd/sites-available/$webname.$ahost.conf
ln -s /etc/httpd/sites-available/$webname.$ahost.conf /etc/httpd/sites-enabled/$webname.$ahost.conf
mkdir /var/www/html/$webname/
echo "This is $webname.$ahost" > /var/www/html/$webname/index.html
systemctl restart httpd
echo -e "$webname\tIN\tA\t$IP" >> /var/named/for.$ahost
systemctl restart named
host $webname.$ahost
curl $webname.$ahost
done
;;

3)
       yum install nfs-utils -y
        IP=`ifconfig | egrep -o "[0-9]{1,3}\.[0-9]{0,3}\.[0-9]{0,3}\.[0-9]{1,3}" | grep -v "^127\|^255\|255$"`
        mkdir /data
        touch /data/secret
        chmod -R 755 /data
        chown nobody:nobody /data -R
        echo -e "/data\t\t*(rw,sync,no_root_squash)" >>  /etc/exports
        systemctl restart nfs-server
        systemctl enable nfs-server
        read -p "Do you want to mount data permanently(y/n)" ch
        if [[ $ch -eq "y" ]]; then
                echo -e "$IP:/data /mnt nfs defaults 0 0" >> /etc/fstab
                mount -a
                df -h
        else
                mount -t nfs $IP:/data /mnt
                df -h
        fi
;;

4)
yum install dhcp-server -y
bhost=`hostname | awk -F"." '{print $2"."$3}'`
read -p "Enter An Network Address :- " ipc
read -p "Enter An Network Mask :- " netmask
read -p "Enter a start range of ip:- " range1
read -p "Enter a end range of ip:- " range2
read -p "Enter a next  server  ip:- " nxtserver
read -p "Enter a gateway:- " gtw
read -p "Enter a hostname for this machine :- " hostname4
cp -av /usr/share/doc/dhcp-server/dhcpd.conf.example /etc/dhcp/dhcpd.conf
#sed -i "7c\ option domain-name \"$bhost\";" /etc/dhcp/dhcpd.conf
#sed -i "8c\ option domain-name-server $hostname4.$bhost;" /etc/dhcp/dhcpd.conf 
sed -i "18c\ authoritative; "  /etc/dhcp/dhcpd.conf 
sed -i "19c\ allow bootp; "  /etc/dhcp/dhcpd.conf 
sed -i "47c\ subnet $ipc netmask $netmask {" /etc/dhcp/dhcpd.conf
sed -i "48c\ \trange dynamic-bootp $range1 $range2;" /etc/dhcp/dhcpd.conf
sed -i "49c\ \toption domain-name-servers $hostname4.$bhost;" /etc/dhcp/dhcpd.conf
sed -i "50c\ \toption domain-name \"$bhost\";" /etc/dhcp/dhcpd.conf
sed -i "51c\ \toption routers $gtw;" /etc/dhcp/dhcpd.conf
sed -i "52c\ \toption broadcast-address 192.168.93.255;" /etc/dhcp/dhcpd.conf
sed -i "53c\ \tdefault-lease-time 600;" /etc/dhcp/dhcpd.conf
sed -i "54c\ \tmax-lease-time 7200;" /etc/dhcp/dhcpd.conf
sed -i "55c\ }" /etc/dhcp/dhcpd.conf
  
systemctl restart dhcpd
systemctl enable dhcpd
;;
5)
yum install tigervnc-server -y
read -p "Enter the user name :- " userN
cp -av /lib/systemd/system/vncserver@.service /etc/systemd/system/vncserver@:3.service
sed -i "55c\ ExecStart=/usr/bin/vncserver_wrapper %i" /etc/systemd/system/vncserver@:3.service
echo ":3=$userN">>/etc/tigervnc/vncserver.users
vncserver
firewall-cmd --zone=public --add-service=vnc-server --permanent
firewall-cmd --reload
systemctl start vncserver@:3.service
systemctl enable vncserver@:3.service
;;
6)
 yum install chrony -y
 # vim /etc/chrony.conf 
sed -i "1c\server 0.in.pool.ntp.org iburst " /etc/chrony.conf 
sed -i "2c\server 1.in.pool.ntp.org iburst " /etc/chrony.conf 
sed -i "3c\server 2.in.pool.ntp.org iburst " /etc/chrony.conf 
sed -i "4c\server 3.in.pool.ntp.org iburst "  /etc/chrony.conf 
echo "allow 192.168.1.0/24" >> /etc/chrony.conf
systemctl restart chronyd
systemctl enable chronyd
chronyc clients
;;
7)
yum install squid -y
systemctl restart squid
systemctl enable squid

firewall-cmd --zone=public --add-service=squid --permanent
firewall-cmd --reload

squid -v
echo -e "Menu \n 1.Allow local network \n 2.block domains \n 3.allow specific website \n 4.Block specific words \n 6.block files \n 7.Set working hours"
read cho
case $cho in 
1)
read -p "Enter how many network you want to ban :- " sa
for i in `seq $sa`; do
read -p "Enter the network $1 you want to ban :- " ips
sed -i "1i acl localnet$i src $ips/24 \nhttp_access allow localnet$i \n" amit
done
;;
2)
read -p "Enter website you want to ban :- " sa1
sed -i '1i acl blocksite$i dstdomain $sa1\nhttp_access deny blocksite$i \n' amit
;;
3)
read -p "Enter the list of block list" blockList
echo $blockList | tr ',' '\n' > /etc/squid/blockedsites.squid
sed -i '1i acl blocksites dstdomain \"/etc/squid/blockedsites.squid\"\nhttp_access deny blocksites \n' amit
systemctl restart squid.service
;;
4)
read -p "Enter the list of block list" banKeyword
echo $banKeyword | tr ',' '\n' > /etc/squid/ban_keywords.txt
sed -i '1i acl bad_keywords url_regex \"/etc/squid/ban_keywords.txt \"\nhttp_access deny bad_keywords \n' amit
systemctl restart squid.service
;;
5)
read -p "Enter the list of block list" blockfiles
echo $blockfiles | tr ',' '\n' > /etc/squid/blockfiles.squid
sed -i '1i acl blockfiles urlpath_regex \"/etc/squid/blockfiles.squid\" \nhttp_access deny blockfiles \n' amit
systemctl restart squid.service
;;
6)
sed -i '1i acl working_hours time 10:00-17:00 \nhttp_access deny working_hours \n' amit
;;
*)
echo "wrong choice"
;;
esac
;;
8)
# Install Kerberos server software
sudo apt-get update
sudo apt-get install krb5-kdc krb5-admin-server -y

# Backup the Kerberos configuration files
sudo cp /etc/krb5.conf /etc/krb5.conf.bak
sudo cp /etc/krb5kdc/kdc.conf /etc/krb5kdc/kdc.conf.bak

# Define the Kerberos realm and KDC settings
REALM="EXAMPLE.COM"
KDC="kerberos.example.com"

# Configure the Kerberos server
sudo sed -i "s/kerberos.example.com/$KDC/g" /etc/krb5.conf
sudo sed -i "s/EXAMPLE.COM/$REALM/g" /etc/krb5.conf
sudo sed -i "s/EXAMPLE.COM/$REALM/g" /etc/krb5kdc/kdc.conf
sudo sed -i "s/kerberos.example.com/$KDC/g" /etc/krb5kdc/kdc.conf

# Create the Kerberos database
sudo kdb5_util create -s -r $REALM

# Create a Kerberos principal for the admin user
sudo kadmin.local -q "addprinc admin/admin"

# Create a Kerberos principal for a sample user
sudo kadmin.local -q "addprinc user1"

# Restart the Kerberos server
sudo systemctl restart krb5-kdc krb5-admin-server

echo "Kerberos server setup complete."
;;
9)
yum install samba samba-common samba-client -y
mkdir /admin
chmod -R 755 /admin
chown -R nobody:nobody /admin

useradd smbuser
smbpasswd -a smbuser
groupadd smb_group
usermod -G smb_group smbuser
chmod -R 770 /admin
chown -R root:smb_group /admin

# vim /etc/samba/smb.conf
[admin]
path = /admin
valid users = @smb_group
guest ok = no
writable = no
browsable = yes

systemctl restart smb
systemctl restart nmb

;;
10)
yum install postfix -y

yum install dovecot -y
sed -i "24c\ protocols = imap pop3 lmtp submission" /etc/dovecot/dovecot.conf
#sed -i "30c\ listen *;" /etc/dovecot/dovecot.conf
sed -i "100c\ unix_listener auth-userdb {" /etc/dovecot/conf.d/10-master.conf
sed -i "101c\ mode = 0666" /etc/dovecot/conf.d/10-master.conf
sed -i "102c\ user = postfix" /etc/dovecot/conf.d/10-master.conf
sed -i "103c\ group = postfix" /etc/dovecot/conf.d/10-master.conf
sed -i "104c\ }" /etc/dovecot/conf.d/10-master.conf
sed -i "10c\ disable_plaintext_auth = no" /etc/dovecot/conf.d/10-auth.conf
sed -i "100c\ auth_mechanisms = plain login" /etc/dovecot/conf.d/10-auth.conf
sed -i "8c\ ssl = no" /etc/dovecot/conf.d/10-ssl.conf
sed -i "24c\ mail_location = maildir:~/Maildir" /etc/dovecot/conf.d/10-mail.conf
systemctl restart dovecot postfix
systemctl enable dovecot postfix
yum install thunderbird -y

thunderbird
;;
11)
exit 0
;;
*)
echo "wrong choice try again"
;;
esac
done
