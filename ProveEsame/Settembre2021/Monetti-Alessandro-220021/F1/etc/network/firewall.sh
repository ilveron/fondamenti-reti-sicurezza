#!/usr/bin/sh

# Pulisco catene
iptables -F
iptables -X

# Policies di default
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

# GREEN può aprire nuove comunicazioni verso tutti
## Creo sotto-catene
iptables -N greenAll
iptables -N allGreen

## Aggancio a catene di default
iptables -A FORWARD -i eth2 -s networkAreaGreen/22 -j greenAll
iptables -A FORWARD -o eth2 -d networkAreaGreen/22 -j allGreen

## Creo regole per sotto-catene
iptables -A greenAll -j ACCEPT
iptables -A allGreen -m state --state ESTABLISHED,RELATED -j ACCEPT


# RED può aprire nuove comunicazioni verso INET e DMZ
## Creo sotto-catene
iptables -N redOthers
iptables -N othersRed

## Aggancio a catene di default
iptables -A FORWARD -i eth1 -o eth0 -s networkAreaRed/23 ! -d 10.0.0.0/8 -j redOthers
iptables -A FORWARD -i eth1 -o eth2 -s networkAreaRed/23 -d networkAreaDmz/22 -j redOthers
iptables -A FORWARD -o eth1 -i eth0 -d networkAreaRed/23 ! -s 10.0.0.0/8 -j othersRed
iptables -A FORWARD -o eth1 -i eth2 -d networkAreaRed/23 -s networkAreaDmz/22 -j othersRed

## Creo regole per sotto-catene
iptables -A redOthers -j ACCEPT
iptables -A othersRed -m state --state ESTABLISHED,RELATED -j ACCEPT

# DMZ può ricevere nuove comunicazioni solo da INET e RED (Quindi solo INET, perchè RED ha già una regola in redOthers)
## Creo sotto-catene
iptables -N dmzInet
iptables -N inetDmz

## Aggancio a catene di default
iptables -A FORWARD ! -d 10.0.0.0/8 -s networkAreaDmz/22 -o eth0 -i eth2 -j dmzInet
iptables -A FORWARD ! -s 10.0.0.0/8 -d networkAreaDmz/22 -i eth0 -o eth2 -j inetDmz

## Creo regole per sotto-catene
iptables -A inetDmz -j ACCEPT
iptables -A dmzInet -m state --state ESTABLISHED,RELATED -j ACCEPT

# Natting
## Port Forwarding verso i server in DMZ
### DNAT verso sFTP (porta 22)
iptables -t nat PREROUTING ! -s 10.0.0.0/8 -i eth0 -d networkAreaDmz/22 -p tcp --dport 22 -j DNAT --to SNatted1[eth0]

### DNAT verso SMTP (porta 25)
iptables -t nat PREROUTING ! -s 10.0.0.0/8 -i eth0 -d networkAreaDmz/22 -p tcp --dport 25 -j DNAT --to S1[eth0]

## SNAT
iptables -t nat POSTROUTING -s 10.0.0.0/8 ! -d 10.0.0.0/8 -o eth0 -j MASQUERADE