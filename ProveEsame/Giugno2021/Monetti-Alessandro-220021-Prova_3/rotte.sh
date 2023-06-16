#!/usr/bin/sh

# Rotte di F1
## Direttamente connesse: TAP, RED, CD2
route add -net networkAreaDmz/23 gw R1[eth3] dev eth2   # DMZ
route add -net networkAreaGreen/24 gw R1[eth3] dev eth2 # GREEN
route add -net networkCd4/30 gw R1[eth3] dev eth2       # CD4
route add -net networkCd5/30 gw R1[eth3] dev eth2       # CD5
route add default gw TAP[tap0] dev eth0                 # Default (INET)

# Rotte di R1
## Direttamente connesse: CD4, DMZ, CD2
route add -net networkAreaGreen/24 gw F2[eth0] dev eth0 # GREEN
route add -net networkCd5/30 gw F2[eth0] dev eth0       # CD5
route add default gw F1[eth2] dev eth3                  # Default (RED, INET)

# Rotte di F2
## Direttamente connesse: CD4, CD5
route add -net networkAreaGreen/24 gw R3[eth0] dev eth1 # GREEN
route add default gw R1[eth0] dev eth0                  # Default (DMZ, CD2, RED, INET)

# Rotte di R3
## Direttamente connesse: CD5, GREEN
route add default gw F2[eth1] dev eth0                  # Default (CD4, DMZ, CD2, RED, INET)