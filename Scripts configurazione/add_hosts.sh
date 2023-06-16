#!/usr/bin/bash


# function to add host to /etc/hosts
add_host() {
	# Add hosts to /etc/hosts if they are not already there
	if ! grep -q "$2" /etc/hosts; then
		echo "$1	$2" >> /etc/hosts
	fi
}

add_host 10.0.7.14 F1
add_host 10.0.7.2 R1
add_host 10.0.7.6 F2
add_host 10.0.7.10 R2


