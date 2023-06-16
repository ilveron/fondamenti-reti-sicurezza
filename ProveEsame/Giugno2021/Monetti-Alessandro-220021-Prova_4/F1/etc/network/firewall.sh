#!/usr/bin/shù

# Pulizia catene
iptables -F
iptables -X

# Imposta policies di default
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

# GREEN può aprire comunicazioni con tutti
## Crea sotto-catene
iptables -N greenAll
iptables -N allGreen

## Aggancio a catene di default
iptables -A FORWARD -i eth1 -s networkAreaGreen/23 -j greenAll
iptables -A FORWARD -o eth1 -d networkAreaGreen/23 -j allGreen

## Crea regole per sotto-catene
iptables -A greenAll -j ACCEPT
iptables -A allGreen -m state --state ESTABLISHED,RELATED -j ACCEPT

# RED può comunicare solo verso INET
## Crea sotto-catene
iptables -N redInet
iptables -N inetRed 

## Aggancio a catene di default
iptables -A FORWARD -i eth2 -o eth0 -s networkAreaRed/22 ! -d 10.0.0.0/8 -j redInet
iptables -A FORWARD -o eth2 -i eth0 -d networkAreaRed/22 ! -s 10.0.0.0/8 -j inetRed

## Crea regole per sotto-catene
iptables -A redInet -j ACCEPT
iptables -A inetRed -m state --state ESTABLISHED,RELATED -j ACCEPT

# DMZ può ricevere nuove comunicazioni solo da INET e GREEN (GREEN già può farlo tramite allGreen)
## Crea sotto-catene
iptables -N dmzInet
iptables -N inetDmz

## Aggancio a catene di default
iptables -A FORWARD -o eth0 -i eth2 ! -d 10.0.0.0/8 -s networkAreaDmz/25 -j dmzInet
iptables -A FORWARD -i eth0 -o eth2 ! -s 10.0.0.0/8 -d networkAreaDmz/25 -j inetDmz

## Crea regole per sotto-catene
iptables -A dmzInet -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A inetDmz -j ACCEPT

# Natting
## Tutti i server dell'area DMZ devono essere raggiungibili dall'esterno
## tramite l'indirizzo ip pubblico del firewall più esterno
### Port Forwarding S2 (SMTP - porta 25)
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 25 -j DNAT --to S2[eth0]
iptables -t nat -A POSTROUTING -p tcp --sport 25 -s S2[eth0] -o eth0 -j MASQUERADE

### Port Forwarding S1 (DNS - porta 53 UDP)
iptables -t nat -A PREROUTING -i eth0 -p udp --dport 53 -j DNAT --to S1[eth0]
iptables -t nat -A POSTROUTING -o eth0 -p udp --sport 53 -s S1[eth0] -j MASQUERADE

