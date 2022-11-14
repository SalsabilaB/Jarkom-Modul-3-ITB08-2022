# Jarkom-Modul-3-ITB08-2022

## Anggota:
| Nama                      | NRP        |
|---------------------------|------------|
| Salsabila Briliana A. S.  | 5027201003 |
| Muhammad Rifqi Fernanda   | 5027201050 |
| Gilang Bayu Gumantara     | 5027201062 | 

## Gambar Topologi

gambar

Melakukan konfigurasi untuk setiap node sebagai berikut :


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

gambarr

## Soal 3,4,5
Ada beberapa kriteria yang ingin dibuat oleh Loid dan Franky, yaitu:
- Semua client yang ada HARUS menggunakan konfigurasi IP dari DHCP Server.
- Client yang melalui Switch1 mendapatkan range IP dari [prefix IP].1.50 - [prefix IP].1.88 dan [prefix IP].1.120 - [prefix IP].1.155 (3)
- Client yang melalui Switch3 mendapatkan range IP dari [prefix IP].3.10 - [prefix IP].3.30 dan [prefix IP].3.60 - [prefix IP].3.85 (4)
- Client mendapatkan DNS dari WISE dan client dapat terhubung dengan internet melalui DNS tersebut. (5)

## Solution


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

