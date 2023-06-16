#!/usr/bin/sh

#Rotte di F1
## Direttamente connesse: TAP, RED, CD2
route add -net networkAreaGreen/22 gw R1[eth3] dev eth2 # GREEN
route add -net networkAreaDmz/22 gw R1[eth3] dev eth2   # DMZ
route add -net networkCd4/30 gw R1[eth3] dev eth2       # CD4
route add -net networkCd5/30 gw R1[eth3] dev eth2       # CD5
#route add -net 10.0.0.0/8 gw R1[eth3] dev eth2
route add default gw TAP[tap0] dev eth0                 # Default

#Rotte di R1
## Direttamente connesse: CD4, GREEN, CD2
route add -net networkAreaDmz/22 gw F2[eth0] dev eth0   # DMZ
route add -net networkCd5/30 gw F2[eth0] dev eth0       # CD5
route add default gw F1[eth2] dev eth3                  # Default


#Rotte di F2
## Direttamente connesse: CD4, CD5
route add -net networkAreaDmz/22 gw R3[eth0] dev eth1   # DMZ
route add default gw R1[eth0] dev eth0                  # Default

#Rotte di R3
## Direttamente connesse: CD5, DMZ
route add default gw F2[eth1] dev eth0                  # Default