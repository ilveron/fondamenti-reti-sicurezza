#!/bin/sh

# Crea interfaccia di rete tap0
tunctl -g netdev -t tap0
ifconfig tap0 10.0.7.14/30
# ifconfig tap0 netmask 255.255.255.252
# ifconfig tap0 broadcast 10.0.7.15
ifconfig tap0 up

# Crea regole di firewalling (cambiare eno1 con il nome della propria scheda di rete)
iptables -t nat -F 	# Flush tabella NAT 
iptables -t nat -X	# Rimuove tutte le catene custom (all'interno della table NAT)	
iptables -F		# Flush firewall
iptables -X		# Rimuove tutte le catene custom (dal firewall)
iptables -t nat -A POSTROUTING -o eno1 -j MASQUERADE 	# Se va verso eno1 "jump" su MASQUERADE
iptables -A FORWARD -i tap0 -j ACCEPT			# Permetti di inoltrare tutto ciò che arriva da tap0

# Abilita il forwarding su host locale
sysctl -w net.ipv4.ip_forward=1

# Aggiunge le rotte alle varie subnets (DA AGGIUNGERE SOLO PER TESTARE LA VOSTRA RETE
# route add -net 10.0.2.0/24 gw 10.0.3.6 dev tap0
# route add -net 10.0.3.0/30 gw 10.0.3.6 dev tap0
# route add -net 10.0.0.0/23 gw 10.0.3.6 dev tap0
route add -net 10.0.0.0/8 gw 10.0.7.13 dev tap0
