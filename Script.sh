#WISE
echo "nameserver 192.168.122.1" > /etc/resolv.conf
apt-get update
apt-get install bind9 -y
apt-get install lynx -y
service bind9 start

echo "options {
        directory \"/var/cache/bind\";

        forwarders {
                192.168.122.1;
       };

        allow-query{any;};
        auth-nxdomain no;    # conform to RFC1035
        listen-on-v6 { any; };
}; " > /etc/bind/named.conf.options

service bind9 restart


#Westalis
echo "nameserver 192.168.122.1" > /etc/resolv.conf
apt-get update
apt-get install isc-dhcp-server -y

echo "INTERFACES=\"eth0\" " > /etc/default/isc-dhcp-server

service isc-dhcp-server start

echo "
subnet 192.218.2.0 netmask 255.255.255.0 {
}
subnet 192.218.1.0 netmask 255.255.255.0 {
    range 192.218.1.50 192.218.1.88;
    range 192.218.1.120 192.218.1.155;
    option routers 192.218.1.1;
    option broadcast-address 192.218.1.255;
    option domain-name-servers 192.218.2.2;
    default-lease-time 300;
    max-lease-time 6900;
}

subnet 192.218.3.0 netmask 255.255.255.0 {
    range 192.218.3.10 192.218.3.30;
    range 192.218.3.60 192.218.3.85;
    option routers 192.218.3.1;
    option broadcast-address 192.218.3.255;
    option domain-name-servers 192.218.2.2;
    default-lease-time 600;
    max-lease-time 6900;
}
host Eden {
    hardware ethernet 36:98:4c:ce:8c:7f;
    fixed-address 192.218.3.13;
} " > /etc/dhcp/dhcpd.conf

service isc-dhcp-server restart


#Berlint
echo "nameserver 192.168.122.1" > /etc/resolv.conf
apt-get update
apt-get install squid -y
service squid start

apt-get install php -y
apt-get install apache2 -y
apt-get install libapache2-mod-php7.0 -y

mv /etc/squid/squid.conf /etc/squid/squid.conf.bak

echo "http_port 8080
visible_hostname Berlint " > /etc/squid/squid.conf

echo "acl AVAILABLE_WORKING time MTWHF 00:00-08:01
acl AVAILABLE_WORKING time MTWHF 17:01-23:59
acl AVAILABLE_WORKING time AS 00:00-23:59 " > /etc/squid/acl.conf

echo "include /etc/squid/acl.conf

http_port 8080
http_access allow AVAILABLE_WORKING
http_access deny all
visible_hostname Berlint " > /etc/squid/squid.conf

echo "loid-work.com
franky-work.com " > /etc/squid/allow-sites.acl

echo "http_port 8080
visible_hostname Berlint

acl ALLOWS dstdomain "/etc/squid/allow-sites.acl"
http_access deny all
http_access allow ALLOWS " >> /etc/squid/squid.conf

service squid restart


#Ostania
apt-get update
apt-get install nano -y
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s 192.218.0.0/16
apt-get install isc-dhcp-relay -y
service isc-dhcp-relay start

echo "SERVERS=\"192.218.2.4\"
INTERFACES=\"eth1 eth3 eth2\"
OPTIONS=\"\"
" > /etc/default/isc-dhcp-relay

echo "net.ipv4.ip_forward=1 " >> /etc/sysctl.conf

service isc-dhcp-relay restart


#SSS
echo "auto eth0
iface eth0 inet dhcp " > /etc/network/interfaces

export http_proxy="http://192.218.2.3:8080"
apt-get update
apt-get install lynx -y


#Garden
echo "auto eth0
iface eth0 inet dhcp " > /etc/network/interfaces


#Eden
apt-get install apache2 -y
service apache2 start
apt-get install php -y
apt-get install libapache2-mod-php7.0 -y
apt-get install ca-certificates openssl -y
echo "auto eth0
iface eth0 inet dhcp
hwaddress ether 36:98:4c:ce:8c:7f " > /etc/network/interfaces
