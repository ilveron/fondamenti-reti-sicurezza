#!/usr/bin/bash

DIR=$HOME/VMs/mount/network-exercise


to_unmount=(F1 R1 F2 R2)

for i in ${to_unmount[@]}; do
    fusermount3 -uz $DIR/$i
done

