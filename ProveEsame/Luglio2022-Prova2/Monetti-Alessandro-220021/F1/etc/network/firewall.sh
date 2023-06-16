#!/usr/bin/sh

# Flush e pulizia catene
iptables -F
iptables -X

# Policies di default
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

# GREEN PUO' APRIRE COMUNICAZIONI VERSO TUTTI
iptables -N greenAll
iptables -N allGreen

iptables -A FORWARD -s networkAreaGreen/21 -i eth2 -j greenAll
iptables -A FORWARD -d networkAreaGreen/21 -o eth2 -j allGreen

iptables -A greenAll -j ACCEPT
iptables -A allGreen -m state --state ESTABLISHED,RELATED -j ACCEPT

# RED PUO' APRIRE COMUNICAZIONI VERSO INET E DMZ
## Verso DMZ (che può ricevere comunicazioni da tutti, quindi scrivo direttamente allDmz e dmzAll)
iptables -N dmzAll
iptables -N allDmz

iptables -A FORWARD -s networkAreaDmz/23 -i eth2 -j dmzAll
iptables -A FORWARD -d networkAreaDmz/23 -o eth2 -j allDmz

iptables -A dmzAll -m state --state ESTABLISHED,RELATED
iptables -A allDmz -j ACCEPT

## Verso INET
iptables -N redInet
iptables -N inetRed

iptables -A FORWARD -s networkAreaRed/22 -o eth0 -j redInet
iptables -A FORWARD -d networkAreaRed/22 -i eth0 -j inetRed

iptables -A redInet -j ACCEPT
iptables -A inetRed -m state --state ESTABLISHED,RELATED

# Abilita ICMP tra GREEN (solo echo-request) e RED (solo echo-reply)
iptables -A FORWARD -p icmp --icmp-type 8 -s networkAreaGreen/21 -d networkAreaRed/22 -i eth2 -j ACCEPT
iptables -A FORWARD -p icmp --icmp-type 0 -s networkAreaRed/21 -d networkAreaGreen/22 -o eth2 -j ACCEPT

# Abilita FORWARD da INET al server web su porta 443 di F2
iptables -A FORWARD -p tcp --dport 443 -i eth0 -d F2[eth2] -j ACCEPT
iptables -A FORWARD -p tcp --dport 443 -i eth0 -d F2[eth2] -m state --state ESTABLISHED, RELATED -j ACCEPT

# Natting
## Port forwarding su S1 (porta 1090 in 443)
iptables -t nat -A PREROUTING -p tcp --dport 1090 -i eth0 -j DNAT --to S1[eth1]:443

## Port forwarding su S3 (porta 5657 in 25)
iptables -t nat -A PREROUTING -p tcp --dport 5657 -i eth0 -j DNAT --to S3[eth0]:25

## SNAT
iptables -t nat -A POSTROUTING -o eth0 -s 10.0.0.0/8 -j MASQUERADE
