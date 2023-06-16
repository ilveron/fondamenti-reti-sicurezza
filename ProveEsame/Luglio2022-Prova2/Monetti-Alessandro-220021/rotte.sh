#!/usr/bin/sh

# Rotte di F1
## Direttamente connesse: TAP, RED, CD3
route add -net networkAreaDmz/23 gw F2[eth2] dev eth2   # Rotta per DMZ
route add -net networkAreaGreen/21 gw F2[eth2] dev eth2 # Rotta per GREEN
route add -net networkCd8/30 gw F2[eth2] dev eth2       # Rotta per CD8
route add default gw TAP[tap0] dev eth0                 # Rotta di default

# Rotte di F2
## Direttamente connesse: CD3, DMZ, CD8
route add -net networkAreaGreen/21 gw R2[eth0] dev eth0 # Rotta per GREEN
route add default gw F1[eth2] dev eth2                  # Rotta di default

# Rotte di R2
## Direttamente connesse: GREEN, CD8
route add default gw F2[eth0] dev eth0                  # Rotta di default