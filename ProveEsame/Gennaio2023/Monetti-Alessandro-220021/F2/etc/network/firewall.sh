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
iptables -A FORWARD -s networkAreaGreen/22 -i eth1 -j greenAll
iptables -A FORWARD -d networkAreaGreen/22 -o eth1 -j allGreen

## Crea nuove regole per sotto-catene
iptables -A greenAll -j ACCEPT
iptables -A allGreen -m state --state ESTABLISHED,RELATED -j ACCEPT

# DMZ <-> ALL
## Crea nuove sotto-catene
iptables -N dmzAll
iptables -N allDmz

## Aggancia a catene di default
iptables -A FORWARD -s networkAreaDmz/23 -i eth0 -j dmzAll
iptables -A FORWARD -d networkAreaDmz/23 -o eth0 -j allDmz

## Crea nuove regole per sotto-catene
iptables -A dmzAll -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A allDmz -j ACCEPT

# Permetti accesso accesso a server porta 8080 su questa macchina solo da INTERNET
iptables -A INPUT -p tcp --dport 8080 -i eth0 ! -s 10.0.0.0/8 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 8080 -m state --state ESTABLISHED,RELATED -o eth0 ! -d 10.0.0.0/8 -j ACCEPT
