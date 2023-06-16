#!/usr/bin/sh

iptables -F # Flush
iptables -X # Rimuovi catene non di default

# Imposta policies di default a DROP
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

# GREEN <-> ALL
## Crea nuove sotto-catene
iptables -N greenAll
iptables -N allGreen

## Aggancia a catene di default
iptables -A FORWARD -s networkAreaGreen/22 -i eth2 -j greenAll
iptables -A FORWARD -d networkAreaGreen/22 -o eth2 -j allGreen

## Crea nuove regole per sotto-catene
iptables -A greenAll -j ACCEPT
iptables -A allGreen -m state --state ESTABLISHED,RELATED -j ACCEPT

# RED <-> INET
## Crea nuove sotto-catene
iptables -N redInet
iptables -N inetRed

## Aggancia a catene di default
iptables -A FORWARD -s networkAreaRed/23 -i eth1 -o eth0 -j redInet
iptables -A FORWARD -d networkAreaRed/23 -i eth0 -o eth1 -j inetRed

## Crea nuove regole per sotto-catene
iptables -A redInet -j ACCEPT
iptables -A inetRed -m state --state ESTABLISHED,RELATED -j ACCEPT

# DMZ <-> ALL
## Crea nuove sotto-catene
iptables -N dmzAll
iptables -N allDmz

## Aggancia a catene di default
iptables -A FORWARD -s networkAreaDmz/23 -i eth2 -j dmzAll
iptables -A FORWARD -d networkAreaDmz/23 -o eth2 -j allDmz

## Crea nuove regole per sotto-catene
iptables -A dmzAll -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A allDmz -j ACCEPT

# Abilita ping tra DMZ e RED
## DMZ può effettuare echo-request verso RED
iptables -A FORWARD -p icmp --icmp-type 8 -s networkAreaDmz/23 -d networkAreaRed/23 -i eth2 -o eth1 -j ACCEPT
## RED può effettuare echo-reply verso DMZ
iptables -A FORWARD -p icmp --icmp-type 0 -s networkAreaRed/23 -d networkAreaDmz/23 -i eth1 -o eth2 -j ACCEPT

# Permetti accesso accesso a server porta 8080 su F2 da INTERNET
iptables -A FORWARD -p tcp --dport 8080 -i eth0 -o eth2 -d F2[eth0] -j ACCEPT
iptables -A FORWARD -p tcp --sport 8080 -m state --state ESTABLISHED,RELATED -o eth0 -i eth2 -s F2[eth0] -j ACCEPT

# Natting
## Port-forwarding per S1 (porta 443 in 4443)
iptables -t nat -A PREROUTING -p tcp --dport 443 -j DNAT -i eth0 --to S1[eth0]:4443
iptables -t nat -A POSTROUTING -p tcp --sport 4443 -s S1[eth0] -j SNAT --to F1[eth0]:443  

## Port-forwarding per S3 (porta 25)
iptables -t nat -A PREROUTING -p tcp --dport 25 -j DNAT -i eth0 --to S3[eth0]
iptables -t nat -A POSTROUTING -p tcp --sport 25 -j SNAT --to F1[eth0]:25

## SNAT
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE