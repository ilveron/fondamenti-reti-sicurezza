#!/usr/bin/sh

# Rotte di F1
## Direttamente connesse: TAP, GREEN, CD2, CD3
route add -net networkAreaRed/23 gw R1[eth0] dev eth3   # RED
route add -net networkAreaDmz/22 gw F2[eth2] dev eth2   # DMZ
route add -net networkCd4/30 gw F2[eth2] dev eth2       # CD4                                 
route add default gw TAP[tap0] dev eth0                 # Default

# Rotte di R1
## Direttamente connesse: CD3, RED
route add default gw F1[eth3] dev eth0                  # Default

# Rotte di F2
## Direttamente connesse: CD4, CD2
route add -net networkAreaDmz/22 gw R2[eth0] dev eth0   # DMZ
route add default gw F1[eth2] dev eth2                  # Default


# Rotte di R2
## Direttamente connesse: CD4, DMZ
route add default gw F2[eth0] dev eth0                  # Default