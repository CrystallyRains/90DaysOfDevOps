#!/bin/bash

# 1. Check if the argument is provided
if [ -z "$1" ]; then
	echo "Error: You must provide a log file path."
	echo "Usage: $0 <logfile>"
	exit 1

# 2. Check if the file actually exists
elif [ ! -f "$1" ]; then
	echo "File doesn't exist"
	echo "Provide the correct filename"
	exit 1
fi

# 3. Create the archive folder safely if it doesn't exist
mkdir -p archive

# 4. Ask the user for confirmation
read -p "Is the log file processed?(y/n): " answer

if [ "$answer" = "y" ]; then
	mv "$1" archive/
	echo "Log file Archived"
else
	echo "Exiting"
	exit 1
fi
