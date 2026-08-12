#!/bin/bash

read -p "Enter the filename:" file_name

if [ -f $file_name ]; then
	echo "File exists"
else
	echo "File doesn't exist"
fi
