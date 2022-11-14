# Jarkom-Modul-3-ITB08-2022

## Anggota:
| Nama                      | NRP        |
|---------------------------|------------|
| Salsabila Briliana A. S.  | 5027201003 |
| Muhammad Rifqi Fernanda   | 5027201050 |
| Gilang Bayu Gumantara     | 5027201062 | 

## Gambar Topologi

![topologi3](https://user-images.githubusercontent.com/90242686/201648721-bfff44d9-692e-42a7-98da-91f7a302f87b.png)

Melakukan konfigurasi untuk setiap node sebagai berikut :
- Ostania
```
auto eth0
iface eth0 inet dhcp

auto eth1
iface eth1 inet static
address 192.218.1.1
netmask 255.255.255.0

auto eth2
iface eth2 inet static
address 192.218.2.1
netmask 255.255.255.0

auto eth3
iface eth3 inet static
address 192.218.3.1
netmask 255.255.255.0
```
- WISE
```
auto eth0
iface eth0 inet static
address 192.218.2.2
netmask 255.255.255.0
gateway 192.218.2.1
```
- Berlint
```
auto eth0
iface eth0 inet static
address 192.218.2.3
netmask 255.255.255.0
gateway 192.218.2.1
```
- Westalis
```
auto eth0
iface eth0 inet static
address 192.218.2.4
netmask 255.255.255.0
gateway 192.218.2.1
```
- SSS, Garden, KemonoPark, NewstonCastle, Eden
```
auto eth0
iface eth0 inet dhcp
```

## Soal 1
Loid bersama Franky berencana membuat peta tersebut dengan kriteria WISE sebagai DNS Server, Westalis sebagai DHCP Server, Berlint sebagai Proxy Server

## Solution
Di WISE, konfigurasi DNS Server dengan menginstall `blind` dengan perintah berikut :
```
echo "nameserver 192.168.122.1" > /etc/resolv.conf
apt-get update
apt-get install bind9 -y
apt-get install lynx -y
service bind9 start
```

Di Westalis, konfigurasi DHCP Server dengan menginstall `isc-dhcp-server` dengan perintah berikut :
```
echo "nameserver 192.168.122.1" > /etc/resolv.conf
apt-get update
apt-get install isc-dhcp-server -y
```

Di Berlint, konfigurasi Proxy Server dengan menginstall `squid` dengan perintah berikut :
```
echo "nameserver 192.168.122.1" > /etc/resolv.conf
apt-get update
apt-get install squid -y
service squid start
```

## Soal 2
dan Ostania sebagai DHCP Relay. Loid dan Franky menyusun peta tersebut dengan hati-hati dan teliti.

## Solution
Di Ostania, konfigurasi DHCP Relay dengan menginstall `isc-dhcp-relay` dengan perintah berikut :
```
apt-get update
apt-get install nano -y
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s 192.218.0.0/16
apt-get install isc-dhcp-relay -y
service isc-dhcp-relay start
```

Kemudian mengedit file `/etc/default/isc-dhcp-relay` seperti gambar dibawah ini :

![ss2](https://user-images.githubusercontent.com/90242686/201653082-b9d70c1e-f260-4d5b-a803-4e8bc8fd60c8.png)


## Soal 3,4,5
Ada beberapa kriteria yang ingin dibuat oleh Loid dan Franky, yaitu:
- Semua client yang ada HARUS menggunakan konfigurasi IP dari DHCP Server.
- Client yang melalui Switch1 mendapatkan range IP dari [prefix IP].1.50 - [prefix IP].1.88 dan [prefix IP].1.120 - [prefix IP].1.155 (3)
- Client yang melalui Switch3 mendapatkan range IP dari [prefix IP].3.10 - [prefix IP].3.30 dan [prefix IP].3.60 - [prefix IP].3.85 (4)
- Client mendapatkan DNS dari WISE dan client dapat terhubung dengan internet melalui DNS tersebut. (5)

## Solution
Membuat konfigurasi pada `/etc/dhcp/dhcpd.conf` di node Westalis sebagai berikut :
```
subnet 192.218.2.0 netmask 255.255.255.0 {
}
subnet 192.218.1.0 netmask 255.255.255.0 {
    range 192.218.1.50 192.218.1.88;       #solusi soal 3
    range 192.218.1.120 192.218.1.155;     #solusi soal 3
    option routers 192.218.1.1;
    option broadcast-address 192.218.1.255;
    option domain-name-servers 192.218.2.2;     #solusi soal 5
    default-lease-time 300;
    max-lease-time 6900;
}

subnet 192.218.3.0 netmask 255.255.255.0 {
    range 192.218.3.10 192.218.3.30;        #solusi soal 4
    range 192.218.3.60 192.218.3.85;        #solusi soal 4
    option routers 192.218.3.1;
    option broadcast-address 192.218.3.255;
    option domain-name-servers 192.218.2.2;     #solusi soal 5 
    default-lease-time 600;
    max-lease-time 6900;
}
```

Kemudian konfigurasi pada `/etc/bind/named.conf.options` di node WISE agar client dapat terhubung ke internet (solusi soal 5)
```
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
```

## Testing

![image](https://user-images.githubusercontent.com/90242686/201653890-41d5cf72-64dd-461f-88fe-7d7fb91249df.png)


![image](https://user-images.githubusercontent.com/90242686/201653963-a156e5e9-879e-41b3-ab82-b9ebf32bd102.png)



## Soal 6
---
Lama waktu DHCP server meminjamkan alamat IP kepada Client yang melalui Switch1 selama 5 menit sedangkan pada client yang melalui Switch3 selama 10 menit. Dengan waktu maksimal yang dialokasikan untuk peminjaman alamat IP selama 115 menit.

### Solution
---
Server Westalis
Pada subnet interface switch 1 dan 3 ditambahkan konfigurasi berikut pada file `/etc/dhcp/dhcpd.conf`

```
subnet 192.218.2.0 netmask 255.255.255.0 {
}
subnet 192.218.1.0 netmask 255.255.255.0 {
    ...
    default-lease-time 300;
    max-lease-time 6900;
}

subnet 192.218.3.0 netmask 255.255.255.0 {
    ...
    default-lease-time 600;
    max-lease-time 6900;
}
```

### Testing
---
- Server SSS (Switch 1)
![testing6a](image/soal6/testing6a.png)
- Server NewstonCastle (Switch 3)
![testing6b](image/soal6/testing6b.png)

## Soal 7
---
Loid dan Franky berencana menjadikan Eden sebagai server untuk pertukaran informasi dengan alamat IP yang tetap dengan IP [prefix IP].3.13

### Solution
---
**Server Westalis**
Menambahkan konfigurasi untuk fixed address pada `/etc/dhcp/dhcpd.conf`

```
host Eden {
    hardware ethernet 36:98:4c:ce:8c:7f;
    fixed-address 192.218.3.13;
}
``` 

**Server Eden**
Setelah itu mengganti konfigurasi pada file `/etc/network/interfaces`

```
auto eth0
iface eth0 inet dhcp
hwaddress ether 36:98:4c:ce:8c:7f
```

### Testing
---
- IP Eden
![testing7](image/soal7/testing7.png)

