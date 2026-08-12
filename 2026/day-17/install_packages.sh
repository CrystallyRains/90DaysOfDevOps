#!/bin/bash

if [ "$EUID" -ne 0 ]; then
	echo "This script needs to be run as root. Please use 'sudo -i' or 'sudo su'."
	exit 1
fi

packg=(nginx curl wget)

apt-get update >/dev/null 2>&1

for i in "${packg[@]}";
do
	{
	if dpkg -s "$i" >/dev/null 2>&1; then
		echo "$i is installed"
	else 
		apt-get install -y "$i"
	fi
	echo "--- Status for $i ---"
	dpkg -s "$i" | grep -E "Package:|Status:"
	echo ""
	}
done

	
