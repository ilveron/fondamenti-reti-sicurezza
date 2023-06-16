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
iptables -A FORWARD -i eth1 -s networkAreaGreen/24 -j greenAll
iptables -A FORWARD -o eth1 -d networkAreaGreen/24 -j allGreen

## Crea regole per sotto-catene
iptables -A greenAll -j ACCEPT
iptables -A allGreen -m state --state ESTABLISHED,RELATED -j ACCEPT