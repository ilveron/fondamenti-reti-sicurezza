#!/usr/bin/sh

# Pulisci e rimuovi catene
iptables -F
iptables -X

# Imposta policies di default
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

# RED può avviare nuove richieste ICMP (solo request) verso GREEN
iptables -A FORWARD -s networkAreaRed/23 -d networkAreaGreen/21 -i eth1 -o eth2 -p icmp --icmp-type 8 -j ACCEPT
iptables -A FORWARD -d networkAreaRed/23 -s networkAreaGreen/21 -o eth1 -i eth2 -p icmp --icmp-type 0 -j ACCEPT

# GREEN può aprire comunicazioni verso tutti
## Crea nuove sotto-catene
iptables -N greenAll
iptables -N allGreen

## Aggancia a catene di default
iptables -A FORWARD -s networkAreaGreen/21 -i eth2 -j greenAll
iptables -A FORWARD -d networkAreaGreen/21 -o eth2 -j allGreen

## Crea regole per sotto-catene
iptables -A greenAll -j ACCEPT
iptables -A allGreen -m state --state ESTABLISHED,RELATED -j ACCEPT

# RED può aprire comunicazioni verso INET e DMZ
# DMZ può ricevere nuove comunicazioni solo da INET e da RED
## Crea nuove sotto-catene
iptables -N allDmz
iptables -N dmzAll

## Aggancia a catene di default
iptables -A FORWARD -s networkAreaDmz/22 -d networkAreaRed/23 -i eth2 -o eth1 -j dmzAll
iptables -A FORWARD -d networkAreaDmz/22 -s networkAreaRed/23  -o eth2 -i eth1 -j allDmz
iptables -A FORWARD -s networkAreaDmz/22 -i eth2 -o eth0 -j dmzAll
iptables -A FORWARD -d networkAreaDmz/22 -i eth0 -o eth2 -j allDmz

## Crea regole per sotto-catene
iptables -A allDmz -j ACCEPT
iptables -A dmzAll -m state --state ESTABLISHED,RELATED -j ACCEPT

# INET può contattare F2 tramite ssh su porta 22
iptables -A FORWARD -p tcp --dport 22 ! -s 10.0.0.0/8 -d F2[eth0] -i eth0 -o eth2 -j ACCEPT
iptables -A FORWARD -p tcp --sport 22 ! -d 10.0.0.0/8 -s F2[eth0] -o eth0 -i eth2 -j ACCEPT

# Natting
## Port forwarding dei server nelle aree DMZ
### S1 - SSH 22
iptables -t nat -A PREROUTING -p tcp --dport 22 -j DNAT --to S1[eth0]

### S2 - SMTP 25
iptables -t nat -A PREROUTING -p tcp --dport 25 -j DNAT --to S2[eth0]

## Maschera ip con uno tra 10.1.1.1, 10.1.1.2, 10.1.1,3
iptables -t nat -A POSTROUTING -s 10.0.0.0/8 -o eth0 -j SNAT --to 10.1.1.1-10.1.1.3