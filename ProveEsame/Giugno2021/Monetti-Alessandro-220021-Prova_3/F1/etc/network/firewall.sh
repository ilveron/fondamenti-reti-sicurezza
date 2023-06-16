#!/usr/bin/sh

# Pulizia catene
iptables -F
iptables -X

# Policies di default
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

# GREEN può aprire comunicazioni verso tutti
## Crea sotto-catene
iptables -N greenAll
iptables -N allGreen

## Aggancia a catene di default
iptables -A FORWARD -i eth2 -s networkAreaGreen/24 -j greenAll
iptables -A FORWARD -o eth2 -d networkAreaGreen/24 -j allGreen

## Crea regole per sotto-catene
iptables -A greenAll -j ACCEPT
iptables -A allGreen -m state --state ESTABLISHED,RELATED -j ACCEPT

# RED può aprire nuove comunicazioni solo verso INET
## Crea sotto-catene
iptables -N redInet
iptables -N inetRed

## Aggancia a catene di default
iptables -A FORWARD -i eth1 -o eth0 -s networkAreaRed/25 -j redInet
iptables -A FORWARD -o eth1 -i eth0 -d networkAreaRed/25 -j inetRed

## Crea regole per sotto-catene
iptables -A redInet -d 10.0.0.0/8 -j DROP
iptables -A inetRed -s 10.0.0.0/8 -j DROP
iptables -A redInet -j ACCEPT
iptables -A inetRed -m state --state ESTABLISHED,RELATED -j ACCEPT

# DMZ può ricevere nuove comunicazioni solo da INET e GREEN (quindi solo INET)
## Crea sotto-catene
iptables -N dmzInet
iptables -N inetDmz

## Aggancia a catene di default
iptables -A FORWARD -i eth2 -o eth0 -s networkAreaDmz/23 -j dmzInet 
iptables -A FORWARD -o eth2 -i eth0 -d networkAreaDmz/23 -j inetDmz 

## Crea regole per sotto-catene
iptables -A dmzInet -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A inetDmz -j ACCEPT

# Natting
## Port Forwarding Snatted1 (SMTP - Porta 25)
iptables -t nat -A PREROUTING -p tcp --dport 25 -j DNAT --to Snatted1[eth0]
iptables -t nat -A POSTROUTING -p tcp --sport 25 -s Snatted1[eth0] -j SNAT --to F1[eth0]

## Port Forwarding S2 (HTTP - Porta 80)
iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to S2[eth0] 
iptables -t nat -A POSTROUTING -p tcp --sport 80 -s S2[eth0] -j SNAT --to F1[eth0]
