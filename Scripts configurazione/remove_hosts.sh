#!/usr/bin/bash

# remove hosts from /etc/hosts
sed -i '/F1/d' /etc/hosts
sed -i '/R1/d' /etc/hosts
sed -i '/F2/d' /etc/hosts
sed -i '/R2/d' /etc/hosts
