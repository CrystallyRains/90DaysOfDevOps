# Day 20 – Bash Scripting Challenge: Log Analyzer and Report Generator

## Objective

Build a Bash script that analyzes a log file and automatically generates a daily summary report.

The script handles:

* Log file validation
* Error counting
* Critical event detection
* Top error message analysis
* Report generation
* Archiving processed logs

---

## 1. Log Analyzer

### `log_analyzer.sh`

```bash
#!/bin/bash

# Check if the argument is provided
if [ -z "$1" ]; then
        echo "Error: You must provide a log file path."
        echo "Usage: $0 <logfile>"
        exit 1

# Check if the file actually exists
elif [ ! -f "$1" ]; then
        echo "File doesn't exist"
        echo "Provide the correct filename"
        exit 1
fi

# Define the report filename
REPORT_FILE="log_report_$(date +%Y-%m-%d).txt"

# Generate the report
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

echo "Success: Summary report generated at $REPORT_FILE"
```

---

## 2. Tools Used

* `grep` – search for `ERROR` and `CRITICAL`
* `awk` – extract specific fields from log lines
* `sort` – sort error messages
* `uniq -c` – count repeated messages
* `head` – display the top 5 results
* `wc -l` – count total lines
* `date` – generate the report date
* `>` – redirect output into the report file

---

## 3. Generated Report

Running the analyzer against `sample_log_file.log` generated:

```text
Date of Analysis: 2026-08-15
log file name: sample_log_file.log
Total lines processed: 200
Total error count: 48

Top 5 error messages with their occurrence count:
12 [ERROR] Disk full
11 [ERROR] Segmentation fault
11 [ERROR] Out of memory
8 [ERROR] Invalid input
6 [ERROR] Failed to

List of critical events with line numbers:
1:2026-08-15 13:24:34 [CRITICAL] - 23274
2:2026-08-15 13:24:34 [CRITICAL] - 6741
3:2026-08-15 13:24:34 [CRITICAL] - 23287
...
```

The final report was saved as:

```text
log_report_2026-08-15.txt
```

---

## 4. Optional: Archive Processed Logs

I also added an `archive_logf.sh` script.

It:

1. Checks whether a log file was provided.
2. Checks whether the file exists.
3. Asks for confirmation before archiving.
4. Creates the `archive/` directory.
5. Moves the processed log file into it.

Example:

```text
Is the log file processed?(y/n): y
Log file Archived
```

Verified the archived file with:

```text
archive % ls
sample_log_file.log
```

---

## 5. What I Learned

### 1. Pipelines can turn raw logs into useful information

Commands such as:

```bash
grep | awk | sort | uniq -c | sort -rn | head
```

can be combined to analyze large amounts of log data quickly.

### 2. Bash can generate useful reports

Instead of printing everything directly to the terminal, multiple commands can be grouped and redirected into a single report file.

### 3. Validation makes scripts safer

Checking arguments and file existence before processing prevents the script from running with invalid input.

---

## Result

Built a Bash-based log analyzer that takes a log file, extracts useful information, generates a dated report, and optionally archives the processed log.

**Day 20 completed. **
