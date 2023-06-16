#!/usr/bin/sh

# Pulizia catene
iptables -F
iptables -X

# Imposta policies di default
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

# GREEN può comunicare con tutti
## Crea sotto-catene
iptables -N greenAll
iptables -N allGreen

## Aggancio a catene di default
iptables -A FORWARD -i eth0 -s networkAreaGreen/23 -j greenAll
iptables -A FORWARD -o eth0 -d networkAreaGreen/23 -j allGreen

## Crea regole per sotto-catene
iptables -A greenAll -j ACCEPT
iptables -A allGreen -m state --state ESTABLISHED,RELATED -j ACCEPT

# DMZ può ricevere nuove comunicazioni solo da INET e GREEN (GREEN verrà gestito successivamente su greenAll)
## Crea sotto-catene
iptables -N dmzInet
iptables -N inetDmz

## Aggancio a catene di default
iptables -A FORWARD -o eth0 -i eth1 -s networkAreaDmz/25 -j dmzInet
iptables -A FORWARD -i eth0 -o eth1 -d networkAreaDmz/25 -j inetDmz

## Crea regole per sotto-catene
iptables -A inetDmz -s 10.0.0.0/8 -j DROP
iptables -A dmzInet -d 10.0.0.0/8 -j DROP
iptables -A dmzInet -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A inetDmz -j ACCEPT
