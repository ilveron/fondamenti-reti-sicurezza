#!/usr/bin/sh
# Creo l'interfaccia tap0
tunctl -g netdev -t tap0
ifconfig 10.0.8.14/30
ifconfig tap0 up

# Flush e pulizia catene da tabella nat e default
iptables -t nat -F
iptables -t nat -X
iptables -F
iptables -X

# Aggiungo regola per SNAT
iptables -t nat -A POSTROUTING -o eno1 -j MASQUERADE
iptables -A FORWARD -i tap0 -j ACCEPT

# Abilito forwarding pacchetti ipv4
sysctl=net.ipv4.ip_forward=1

# Aggiungo rotta per rete interna
route add -net 10.0.0.0/8 gw F1[eth0] dev tap0
