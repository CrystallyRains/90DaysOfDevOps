#!/bin/bash

if [ ! -d "$1" ]; then
{
	echo "Error: Directory does not exist."
	exit 1
}
fi

comp=0
del=0

for file in $(find "$1" -type f -name "*.log" -mtime +7); do
	gzip "$file"
	((comp++))
done


for file in $(find "$1" -type f -name "*.gz" -mtime +30); do
	rm "$file"
	((del++))
done

echo "Total files compressed: $comp"
echo "Total files deleted: $del"

