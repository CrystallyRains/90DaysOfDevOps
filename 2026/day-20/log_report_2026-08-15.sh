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

# 3. Define the report filename exactly as requested (with .txt)
REPORT_FILE="log_report_$(date +%Y-%m-%d).txt" 

# 4. Group all outputs and redirect them into the report file using { ... } > "$REPORT_FILE"
{
	echo "Date of Analysis: $(date +%Y-%m-%d)"
	echo "log file name: $1"
	echo "Total lines processed: $( wc -l < "$1" )"
	echo "Total error count: $(grep -c "ERROR" "$1" )"
	echo "Top 5 error messages with their occurrence count:"
	grep -i "ERROR" "$1" | awk '{print $3, $4, $5}' | sort | uniq -c | sort -rn | head -n 5
	echo "List of critical events with line numbers:"
	grep -in "CRITICAL" "$1"
} > "$REPORT_FILE"

# 5. Print a confirmation message to the terminal screen
echo "Success: Summary report generated at $REPORT_FILE"


 

