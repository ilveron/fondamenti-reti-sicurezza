# Rotte per F1
## Reti direttamente connesse -> RED, CD2, TAP
route add -net networkAreaDmz/23 gw R1[eth3] dev eth2	# Per DMZ
route add -net networkAreaGreen/22 gw R1[eth3] dev eth2 # Per GREEN
route add -net networkCD4/30 gw R1[eth3] dev eth2	# Per CD4	
route add -net networkCD5/30 gw R1[eth3] dev eth2	# Per CD5
route add default gw TAP[tap0] dev eth0			# Rotta di default

# Rotte per R1
## Reti direttamente connesse -> CD2, CD4, DMZ
route add -net networkAreaGreen/22 gw F2[eth0] dev eth0 # Per GREEN
route add -net networkCD5/30 gw F2[eth0] dev eth0	# Per CD5
route add default gw F1[eth2] dev eth3			# Rotta di default

# Rotte per F2
## Reti direttamente connesse -> CD4, CD5
route add -net networkAreaGreen/22 gw R3[eth0] dev eth1 # Per GREEN
route add default gw R1[eth0] dev eth0			# Rotta di default

# Rotte per R3
## Reti direttamente connesse -> CD5, GREEN
route add default gw F2[eth1] dev eth0			# Rotta di default
