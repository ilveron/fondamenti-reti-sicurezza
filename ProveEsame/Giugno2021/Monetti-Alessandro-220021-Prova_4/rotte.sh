#!/usr/bin/sh

# Rotte di F1
## Direttamente connesse: TAP, GREEN, CD2
route add -net networkAreaDmz/25 gw R1[eth3] dev eth2   # DMZ
route add -net networkAreaRed/22 gw R1[eth3] dev eth2   # RED
route add -net networkCd5/30 gw R1[eth3] dev eth2       # CD5
route add -net networkCd4/30 gw R1[eth3] dev eth2       # CD4
route add default gw TAP[tap0] dev eth0                 # Default (INET)

# Rotte di R1
## Direttamente connesse: CD4, RED, CD2
route add -net networkCd5/30 gw F2[eth0] dev eth0       # CD5
route add -net networkAreaDmz/25 gw F2[eth0] dev eth0   # DMZ
route add default gw F1[eth2] dev eth3                  # Default (Green, INET)

# Rotte di F2
## Direttamente connesse: CD4, CD5
route add -net networkAreaDmz/25 gw R3[eth0] dev eth1   # GREEN
route add default gw R1[eth0] dev eth0                  # Default (CD4, CD2, RED, Green, INET)                

# Rotte di R3
## Direttamente connesse: CD5, DMZ
route add default gw F2[eth1] dev eth0