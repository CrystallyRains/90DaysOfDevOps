#!/bin/bash

if [ $# -gt 0 ]; then
	echo "Hello, $1!"
else
	echo "Usage: ./greet.sh <name>"
fi

