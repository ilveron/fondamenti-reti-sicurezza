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
iptables -A FORWARD -i eth2 -o eth0 -s networkAreaRed/23 ! -d 10.0.0.0/8 -j redInet
iptables -A FORWARD -o eth2 -i eth0 -d networkAreaRed/23 ! -s 10.0.0.0/8 -j inetRed

## Crea regole per sotto-catene
iptables -A redInet -j ACCEPT
iptables -A inetRed -m state --state ESTABLISHED,RELATED -j ACCEPT

# DMZ può ricevere nuove comunicazioni solo da INET e GREEN
# (Regola per GREEN già presente, quindi si provvede a creare INET <-> DMZ)
## Crea sotto-catene
iptables -N dmzInet
iptables -N inetDmz

## Aggancia a catene di default
iptables -A FORWARD -o eth0 -i eth1 ! -d 10.0.0.0/8 -s networkAreaDmz/24 -j dmzInet
iptables -A FORWARD -i eth0 -o eth1 ! -s 10.0.0.0/8 -d networkAreaDmz/24 -j inetDmz

## Crea regole per sotto-catene
iptables -A dmzInet -d 10.0.0.0/8 -j DROP
iptables -A dmzInet -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A inetDmz -j ACCEPT

# Natting
## Port Forwarding
### S1 (SSH - porta 22 TCP)
iptables -t nat -A PREROUTING -p tcp --dport 22 -j DNAT --to S1[eth0]
iptables -t nat -A POSTROUTING -p tcp --sport 22 -i eth2 -s S1[eth0] -j SNAT --to F1[eth0]:22