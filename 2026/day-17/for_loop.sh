#!/bin/bash

fruits=("Apple" "Mango" "Banana" "Cherry" "Papaya")
for i in "${fruits[@]}"
do
	{
	echo -e "\n$i"
	}
done
