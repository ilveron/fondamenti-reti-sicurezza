#!/usr/bin/sh

# Pulisci e rimuovi catene
iptables -F
iptables -X

# Imposta policies di default
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

# RED può avviare nuove richieste ICMP (solo request) verso GREEN
iptables -A FORWARD -s networkAreaRed/23 -d networkAreaGreen/21 -i eth0 -o eth1 -p icmp --icmp-type 8 -j ACCEPT
iptables -A FORWARD -d networkAreaRed/23 -s networkAreaGreen/21 -o eth0 -i eth1 -p icmp --icmp-type 0 -j ACCEPT

# GREEN può aprire comunicazioni verso tutti (eccetto DMZ)
## Crea nuove sotto-catene
iptables -N greenAll
iptables -N allGreen

## Aggancia a catene di default
iptables -A FORWARD -s networkAreaGreen/21 -i eth1 ! -d networkAreaDmz/22 -j greenAll   # Tutte eccetto DMZ
iptables -A FORWARD -d networkAreaGreen/21 -o eth1 ! -s networkAreaDmz/22 -j allGreen   # Tutte eccetto DMZ

## Crea regole per sotto-catene
iptables -A greenAll -j ACCEPT
iptables -A allGreen -m state --state ESTABLISHED,RELATED -j ACCEPT

# Permetti collegamento SSH a questa macchina
iptables -A INPUT -p tcp --dport 22 -i eth0 ! -s 10.0.0.0/8 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 22 -o eth0 ! -d 10.0.0.0/8 -m state --state ESTABLISHED,RELATED -j ACCEPT