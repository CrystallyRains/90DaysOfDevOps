#!/bin/bash

name=$1
localf()
{
	local name="Snigs"
	echo "Local name is: $name"
}

regularf()
{
        name="Hacker"  # Missing the 'local' keyword!
        echo "  [Inside regularf] name is: $name"
}



echo "before function"
localf
regularf

echo "after function"
echo " My name is $name"

