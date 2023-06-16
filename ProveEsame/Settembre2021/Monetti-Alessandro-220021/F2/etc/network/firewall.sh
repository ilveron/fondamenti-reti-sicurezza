#!/usr/bin/sh

# Pulisco catene
iptables -F
iptables -X

# Policies di default
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

# RED e INET possono aprire nuove comunicazioni verso DMZ, ma non GREEN
## Creo sotto-catene
iptables -N dmzOthers
iptables -N othersDmz

## Aggancio a catene di default
iptables -A FORWARD -o eth0 -i eth1 ! -d networkAreaGreen/22 -s networkAreaDmz/22 -j dmzOthers
iptables -A FORWARD -i eth0 -o eth1 ! -s networkAreaGreen/22 -d networkAreaDmz/22 -j othersDmz

## Creo regole per sotto-catene
iptables -A othersDmz -j ACCEPT
iptables -A dmzOthers -m state --state ESTABLISHED,RELATED -j ACCEPT