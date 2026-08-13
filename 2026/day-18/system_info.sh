#!/bin/bash

set -euo pipefail

host_os()
{
	echo "Hostname: $(hostname)"
	echo " OS : $(uname -s)"
}

get_uptime()
{
       echo "Uptime: $(uptime)"
}

disk_usage()
{
	echo "disk usage========="
	df -h | sort -hr | head -n 5
}

memory_usage()
{
	echo "free memory========"
	free -h
}

top_cpu()
{
	echo "cpu usage=========="
	ps -eo pid,user,%cpu,comm --sort=-%cpu | head -n 6
}

main()
{
	host_os
	get_uptime
	disk_usage
	memory_usage
	top_cpu
}


main





