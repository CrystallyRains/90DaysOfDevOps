#!/bin/bash

check_disk()
{
	echo "======= DISK Usage =========="
	df -h /
	echo ""
}

check_memory()
{
	echo "========== FREE Memory ================"
	free -h
}

main()
{
	echo "START"
	check_memory
	check_disk
	echo "END"
}

main
