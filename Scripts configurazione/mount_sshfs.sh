#!/usr/bin/bash

DIR=$HOME/VMs/mount/network-exercise


# create directory if it does not exist
if [ ! -d "$DIR" ]; then
    mkdir "$DIR";
fi
to_mount=(F1 R1 F2 R2)

for i in ${to_mount[@]}; do
    # check if the directory exists
    if [ ! -d "$DIR/$i" ]; then
        mkdir "$DIR/$i"
    fi

    # check if the directory is already mounted

    if ! mount | grep -q $DIR/$i; then
        sshfs root@$i:/ $DIR/$i
    else
        echo "$i is already mounted"
    fi
done

