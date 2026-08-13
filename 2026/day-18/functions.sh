#!/bin/bash

function_greet()
{
	name=$1
	echo "Hello, $1"
}


function_greet Snigdha

add()
{	
	addition=$(($1+$2))
	echo "Addition is: $addition"
}

add 5 7
