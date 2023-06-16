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

iptables -A FORWARD -s networkAreaGreen/21 -i eth0 -j greenAll
iptables -A FORWARD -d networkAreaGreen/21 -o eth0 -j allGreen

iptables -A greenAll -j ACCEPT
iptables -A allGreen -m state --state ESTABLISHED,RELATED -j ACCEPT

# RED PUO' APRIRE COMUNICAZIONI VERSO DMZ
## Verso DMZ (che può ricevere comunicazioni da tutti, quindi scrivo direttamente allDmz e dmzAll)
iptables -N dmzRed
iptables -N redDmz

iptables -A FORWARD -s networkAreaDmz/23 -d networkAreaRed/22 -i eth4 -o eth2 -j dmzRed
iptables -A FORWARD -s networkAreaRed/22 -d networkAreaDmz/23 -i eth2 -o eth4 -j redDmz

iptables -A dmzRed -m state --state ESTABLISHED,RELATED
iptables -A redDmz -j ACCEPT

# Abilita ICMP tra GREEN (solo echo-request) e RED (solo echo-reply)
iptables -A FORWARD -p icmp --icmp-type 8 -s networkAreaGreen/21 -d networkAreaRed/22 -i eth0 -o eth2 -j ACCEPT
iptables -A FORWARD -p icmp --icmp-type 0 -s networkAreaRed/21 -d networkAreaGreen/22 -i eth2 -o eth2 -j ACCEPT

# Abilita INPUT da INET e OUTPUT verso INET al server web su porta 443 di questa macchina
iptables -A INPUT -p tcp --dport 443 -i eth2 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 443 -i eth2 -m state --state ESTABLISHED, RELATED -j ACCEPT