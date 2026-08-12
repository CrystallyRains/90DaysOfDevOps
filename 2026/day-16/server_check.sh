#!/bin/bash

read -p "Enter a service name:" svc_name

read -p "Do you want to check the status of $svc_name?" value

if [ "$value" == "y" ]; then
	if systemctl is-active --quiet "$svc_name"; then
        	echo "$svc_name is active"
    	else
        	echo "$svc_name is not active"	
	#sudo systemctl status "$svc_name"
elif [ "$value" == "n" ]; then
	echo "Skipped"
else
	echo "Provide a valid input"
fi
	

