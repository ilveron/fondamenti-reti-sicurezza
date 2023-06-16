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
iptables -A FORWARD -i eth1 -s networkAreaGreen/23 -j greenAll
iptables -A FORWARD -o eth1 -d networkAreaGreen/23 -j allGreen

## Crea regole per sotto-catene
iptables -A greenAll -j ACCEPT
iptables -A allGreen -m state --state ESTABLISHED,RELATED -j ACCEPT

# RED può aprire nuove comunicazioni solo verso INET
## Crea sotto-catene
iptables -N redInet
iptables -N inetRed

## Aggancia a catene di default
iptables -A FORWARD -i eth3 -o eth0 -s networkAreaRed/23 ! -d 10.0.0.0/8 -j redInet
iptables -A FORWARD -o eth3 -i eth0 -d networkAreaRed/23 ! -s 10.0.0.0/8 -j inetRed

## Crea regole per sotto-catene
iptables -A redInet -j ACCEPT
iptables -A inetRed -m state --state ESTABLISHED,RELATED -j ACCEPT

# DMZ può ricevere nuove comunicazioni solo da INET e GREEN (quindi crea regola solo per INET visto che GREEN è già abilitato)
## Crea sotto-catene
iptables -N dmzInet
iptables -N inetDmz

## Aggancia a catene di default
iptables -A FORWARD -i eth2 -o eth0 -s networkAreaDmz/22 ! -d 10.0.0.0/8 -j dmzInet
iptables -A FORWARD -o eth2 -i eth0 -d networkAreaDmz/22 ! -s 10.0.0.0/8 -j inetDmz

## Crea regole per sotto-catene
iptables -A dmzInet -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A inetDmz -j ACCEPT

# Natting
## Port Forwarding
### S4 (porta 80)
iptables -t nat -A PREROUTING -i eth0 ! -s 10.0.0.0/8 -p tcp --dport 80 -j DNAT --to S4[eth0]

### S2 (porta 25)
iptables -t nat -A PREROUTING -i eth0 ! -s 10.0.0.0/8 -p tcp --dport 25 -j DNAT --to S2[eth0]