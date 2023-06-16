#!/usr/bin/sh

# Pulizia e rimozione catene
iptables -F
iptables -X

# Imposta policies di default
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

# GREEN può aprire comunicazioni verso tutti
## Crea sotto-catene
iptables -N greenAll
iptables -N allGreen

## Aggancia a catene di default
iptables -A FORWARD -i eth2 -s networkAreaGreen/23 -j greenAll
iptables -A FORWARD -o eth2 -d networkAreaGreen/23 -j allGreen

## Crea regole per sotto-catene
iptables -A greenAll -j ACCEPT
iptables -A allGreen -m state --state ESTABLISHED,RELATED -j ACCEPT

# DMZ può ricevere nuove comunicazioni solo da INET e GREEN (quindi crea regola solo per INET visto che GREEN è già abilitato)
## Crea sotto-catene
iptables -N dmzInet
iptables -N inetDmz

## Aggancia a catene di default
iptables -A FORWARD -i eth0 -o eth2 -s networkAreaDmz/22 ! -d 10.0.0.0/8 -j dmzInet
iptables -A FORWARD -o eth0 -i eth2 -d networkAreaDmz/22 ! -s 10.0.0.0/8 -j inetDmz

## Crea regole per sotto-catene
iptables -A dmzInet -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A inetDmz -j ACCEPT