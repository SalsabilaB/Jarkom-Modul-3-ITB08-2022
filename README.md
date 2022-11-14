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

## Soal 8

 **SSS**, **Garden, dan Eden** digunakan sebagai client **Proxy** agar pertukaran informasi dapat terjamin keamanannya, juga untuk mencegah kebocoran data.

Pada Proxy Server di **Berlint,** Loid berencana untuk mengatur bagaimana Client dapat mengakses internet. Artinya setiap client harus menggunakan Berlint sebagai HTTP & HTTPS proxy. Adapun kriteria pengaturannya adalah sebagai berikut:

---

1. Client hanya dapat mengakses internet diluar (selain) hari & jam kerja (senin-jumat 08.00 - 17.00) dan hari libur (dapat mengakses 24 jam penuh)
2. Adapun pada hari dan jam kerja sesuai nomor (1), client hanya dapat mengakses domain loid-work.com dan franky-work.com (IP tujuan domain dibebaskan)
3. Saat akses internet dibuka, client dilarang untuk mengakses web tanpa HTTPS. (Contoh web HTTP: [http://example.com](http://example.com/))
4. Agar menghemat penggunaan, akses internet dibatasi dengan kecepatan maksimum 128 Kbps pada setiap host (Kbps = kilobit per second; lakukan pengecekan pada tiap host, ketika 2 host akses internet pada saat bersamaan, **keduanya mendapatkan speed maksimal yaitu 128 Kbps**)
5. Setelah diterapkan, ternyata peraturan nomor (4) mengganggu produktifitas saat hari kerja, dengan demikian pembatasan kecepatan hanya diberlakukan untuk pengaksesan internet pada hari libur

Setelah proxy **Berlint** diatur oleh Loid, dia melakukan pengujian dan mendapatkan hasil sesuai tabel berikut.

| Aksi | Senin (10.00) | Senin (20.00) | Sabtu (10.00) |
| --- | --- | --- | --- |
| Akses internet (HTTP) | x | x | x |
| Akses internet (HTTPS) | x | v | v |
| Akses loid-work.com dan franky-work.com | v | x | x |
| Speed limit (128Kbps) | tidak bisa akses | x (speed tidak dibatasi) | v |

x: tidak

v: iya

## Solution

Konfigurasi domain:

Menambahkan konfigurasi domain [*loid-work.com*](http://loid-work.com) dan [*franky-work.com](http://franky-work.com)* di DNS server yaitu WISE

```
echo "
zone \"loid-work.com\" {
        type master;
        file \"/etc/bind/jarkom/loid-work.com\";
};
zone \"franky-work.com\" {
        type master;
        file \"/etc/bind/jarkom/franky-work.com\";
};
"> /etc/bind/named.conf.local
```

Kemudian menambahkan domain

```
echo "
;
; BIND data file for local loopback interface
;
\$TTL    604800
@       IN      SOA     franky-work.com. root.franky-work.com. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@               IN      NS      franky-work.com.
@               IN      A       192.218.2.2     ; IP WISE
www             IN      CNAME   franky-work.com.
" > /etc/bind/jarkom/franky-work.com

echo "
;
; BIND data file for local loopback interface
;
\$TTL    604800
@       IN      SOA     loid-work.com. root.loid-work.com. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      loid-work.com.
@       IN      A       192.218.2.2     ; IP WISE
www     IN      CNAME   loid-work.com.
" > /etc/bind/jarkom/loid-work.com
```

Memberikan konfigurasi masing-masing domain

```
echo '
<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html
        ServerName loid-work.com
 
        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
' > /etc/apache2/sites-available/loid-work.com.conf

echo '
<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html
        ServerName franky-work.com
 
        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
' > /etc/apache2/sites-available/franky-work.com.conf
```

Menambahkan konfigurasi web agar dicek melalui client proxy dengan lynx

Konfigurasi Proxy:

1. Membatasi akses client dengan hanya bisa mengakses internet pada diluar jam kerja yaitu senin sampai jumat jam 08.00 sampai 17.00 

Mendeklarasikan waktu kerja dan di luar kerja, lalu memberikan hak akses diluar jam kerja
    
```
    acl WORKTIME time MTWHF 08:00-17:00
    acl WEEKEND time SA 00:00-23:59
```
    
```
    http_access allow !WORKTIME
    http_access deny all
```
    
2. Hanya bisa mengakses domain kerja (**loid-work.com & franky-work.com**) pada saat jam kerja

Mendeklarasikan sejumlah domain kerja dan memberikan hak akses pada saat jam kerja
    
```
    echo '
    loid-work.com
    franky-work.com
    ' > /etc/squid/work-sites.acl
    
    acl WORKSITE dstdomain "/etc/squid/working-sites.acl"
 ```
    
 ```
    http_access allow WORKSITE WORKTIME
 ```
    
3. Hanya memperbolehkan HTTPS (tidak boleh melalui HTTP)

Karena port HTTPS adalah 443, maka kita deklarasikan portnya lalu melarang semua akses yang tidak melewati port 443 
    
```
    acl GOODPORT port 443
    acl CONNECT method CONNECT
```
    
```
    http_access deny !GOODPORT
    http_access deny CONNECT !GOODPORT
```
    
4. Pembatasan kecepatan internet menjadi 128Kbps

Mengubah parameter internet menjadi 16000/16000 untuk membatasi kecepatan internet menjadi 128Kbps
    
```
    delay_pools 1
    delay_class 1 1
    delay_parameters 1 16000/16000
 ```
    
5. Pembatasan dilakukan hanya pada saat hari sabtu dan minggu

Menambahkan konfigurasi bandwidth 
```
    delay_pools 1
    delay_class 1 1
    delay_access 1 allow WEEKEND_TIME
    delay_parameters 1 16000/16000
```
    
## Testing 
Berhasil mengakses

![berhasil](https://user-images.githubusercontent.com/90242686/201681432-e5751da4-331a-4b14-9441-b66dff954e07.png)

Gagal mengakses

![gagal](https://user-images.githubusercontent.com/90242686/201681455-509a9f87-e877-431a-a8ea-0bbd92a91ed3.png)

