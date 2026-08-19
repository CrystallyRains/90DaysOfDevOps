# Shell Scripting Cheat Sheet

A quick Bash reference for DevOps work.

## Quick Reference

| Topic | Key Syntax | Example |
|---|---|---|
| Variable | `VAR="value"` | `NAME="DevOps"` |
| Argument | `$1`, `$2`, `$#`, `$@` | `./script.sh arg1 arg2` |
| If | `if [ condition ]; then` | `if [ -f file ]; then` |
| For loop | `for i in list; do` | `for i in 1 2 3; do` |
| While | `while [ condition ]; do` | `while [ "$count" -lt 5 ]; do` |
| Function | `name() { ... }` | `greet() { echo "Hi"; }` |
| Grep | `grep pattern file` | `grep -i "error" app.log` |
| Awk | `awk '{print $1}' file` | `awk -F: '{print $1}' /etc/passwd` |
| Sed | `sed 's/old/new/g' file` | `sed -i 's/foo/bar/g' config.txt` |
| Find | `find path -type f` | `find . -name "*.log"` |
| Exit status | `$?` | `echo $?` |

---

## 1. Basics

### Shebang

Tells the operating system which interpreter should run the script.

```bash
#!/bin/bash
```

### Running a Script

```bash
chmod +x script.sh
./script.sh

# Run without execute permission
bash script.sh
```

### Comments

```bash
# This is a single-line comment
echo "Hello"  # This is an inline comment
```

### Variables

No spaces around `=` when assigning a variable.

```bash
name="Snigdha"
echo "$name"
```

**Quoting matters:**

```bash
echo $name       # Unquoted
echo "$name"     # Double quotes: expands variable, preserves spaces
echo '$name'     # Single quotes: prints literal $name
```

**Rule:** Prefer `"$VAR"` when using variables.

### Reading Input

```bash
read -p "Enter your name: " name
echo "Hello, $name"
```

### Command-Line Arguments

```bash
echo "Script: $0"
echo "First argument: $1"
echo "Total arguments: $#"
echo "All arguments: $@"
```

`$?` = exit status of the previous command.

```bash
ls /tmp
echo "$?"
```

`0` means success; non-zero means failure.

---

## 2. Operators and Conditionals

### String Comparisons

```bash
if [ "$name" = "Alice" ]; then
    echo "Match"
fi

[ "$name" != "Bob" ]
[ -z "$name" ]   # Empty
[ -n "$name" ]   # Not empty
```

### Integer Comparisons

| Operator | Meaning |
|---|---|
| `-eq` | equal |
| `-ne` | not equal |
| `-lt` | less than |
| `-gt` | greater than |
| `-le` | less than or equal |
| `-ge` | greater than or equal |

```bash
if [ "$age" -ge 18 ]; then
    echo "Adult"
fi
```

For arithmetic, `(( ))` is also useful:

```bash
if (( count > 5 )); then
    echo "Greater than 5"
fi
```

### File Tests

| Operator | Checks |
|---|---|
| `-e` | Path exists |
| `-f` | Regular file |
| `-d` | Directory |
| `-r` | Readable |
| `-w` | Writable |
| `-x` | Executable |
| `-s` | File exists and is not empty |

```bash
if [ -f "app.log" ]; then
    echo "Log file exists"
fi
```

### if / elif / else

```bash
if [ "$score" -ge 90 ]; then
    echo "A"
elif [ "$score" -ge 50 ]; then
    echo "Pass"
else
    echo "Fail"
fi
```

### Logical Operators

```bash
# AND
[ -f "$file" ] && echo "File exists"

# OR
[ -f "$file" ] || echo "File missing"

# NOT
if [ ! -f "$file" ]; then
    echo "File does not exist"
fi
```

### case

Useful when one value can have multiple possible options.

```bash
case "$1" in
    start)
        echo "Starting"
        ;;
    stop)
        echo "Stopping"
        ;;
    *)
        echo "Usage: $0 {start|stop}"
        ;;
esac
```

---

## 3. Loops

### List-Based for Loop

```bash
for server in web1 web2 web3; do
    echo "Checking $server"
done
```

### Numeric Range

```bash
for i in {1..5}; do
    echo "$i"
done
```

### C-Style for Loop

```bash
for (( i=1; i<=5; i++ )); do
    echo "$i"
done
```

### while Loop

Runs while the condition is true.

```bash
count=1

while [ "$count" -le 5 ]; do
    echo "$count"
    ((count++))
done
```

### until Loop

Runs until the condition becomes true.

```bash
count=1

until [ "$count" -gt 5 ]; do
    echo "$count"
    ((count++))
done
```

### break

Stops the loop completely.

```bash
for i in {1..10}; do
    if [ "$i" -eq 5 ]; then
        break
    fi
    echo "$i"
done
```

### continue

Skips the current iteration.

```bash
for i in {1..5}; do
    if (( i == 3 )); then
        continue
    fi
    echo "$i"
done
```

### Loop Over Files

```bash
for file in *.log; do
    [ -f "$file" ] || continue
    echo "Processing $file"
done
```

### Read Command Output Line-by-Line

```bash
while read -r line; do
    echo "$line"
done < <(command)
```

`read -r` prevents backslashes from being interpreted.

---

## 4. Functions

Functions make scripts reusable and easier to maintain.

### Define and Call

```bash
greet() {
    echo "Hello!"
}

greet
```

### Function Arguments

Function arguments use `$1`, `$2`, etc. inside the function.

```bash
greet() {
    echo "Hello, $1"
}

greet "Snigdha"
```

### return vs echo

`return` sends an exit status; use `echo` when you need to return actual data.

```bash
check_file() {
    [ -f "$1" ]
}

check_file "app.log"
echo "$?"
```

```bash
get_name() {
    echo "DevOps"
}

name=$(get_name)
echo "$name"
```

### Local Variables

Use `local` so a function variable does not affect the rest of the script.

```bash
backup() {
    local backup_dir="/tmp/backups"
    echo "$backup_dir"
}
```

---

## 5. Text Processing Commands

### grep

Search for matching text.

```bash
grep "ERROR" app.log
grep -i "error" app.log       # Ignore case
grep -r "ERROR" /var/log       # Recursive
grep -c "ERROR" app.log       # Count matches
grep -n "ERROR" app.log       # Show line numbers
grep -v "INFO" app.log        # Exclude matches
grep -E "ERROR|CRITICAL" app.log
```

### awk

Useful for processing columns and structured text.

```bash
awk '{print $1}' file.txt
awk -F: '{print $1}' /etc/passwd
awk '/ERROR/ {print $3}' app.log
awk 'BEGIN {print "START"} {print $1} END {print "DONE"}' file.txt
```

- `$1`, `$2` = columns
- `$0` = complete line
- `-F` = field separator
- `BEGIN` = before processing
- `END` = after processing

### sed

Modify or filter text.

```bash
sed 's/old/new/g' file.txt       # Replace
sed '3d' file.txt                # Delete line 3
sed '/^#/d' file.txt             # Delete comment lines
sed -i 's/foo/bar/g' config.txt  # Edit file directly
```

### cut

Extract columns from delimited data.

```bash
cut -d "," -f 1 users.csv
cut -d ":" -f 1,5 /etc/passwd
```

`-d` = delimiter, `-f` = field.

### sort

```bash
sort names.txt
sort -n numbers.txt
sort -rn numbers.txt
sort -u names.txt
```

- default = alphabetical
- `-n` = numeric
- `-r` = reverse
- `-u` = unique

### uniq

Works on adjacent duplicate lines, so use `sort` first when needed.

```bash
sort names.txt | uniq
sort access.log | uniq -c
```

`-c` counts occurrences.

### tr

Translate or delete characters.

```bash
echo "hello" | tr 'a-z' 'A-Z'
echo "hello123" | tr -d '0-9'
```

### wc

```bash
wc -l app.log   # Lines
wc -w app.log   # Words
wc -c app.log   # Bytes
```

### head / tail

```bash
head -n 5 app.log
tail -n 20 app.log
tail -f /var/log/nginx/access.log
```

`tail -f` is especially useful for watching logs in real time.

### Useful Pipeline

Find the top 3 most frequent IPs in an access log:

```bash
cut -d " " -f 1 access.log | sort | uniq -c | sort -rn | head -n 3
```

---

## 6. Useful DevOps One-Liners

### Find files older than 7 days

```bash
find /var/log -type f -mtime +7
```

Delete them only when you're sure:

```bash
find /var/log -type f -mtime +7 -delete
```

### Count lines in all `.log` files

```bash
wc -l *.log
```

### Replace a string across `.conf` files

```bash
sed -i 's/old_value/new_value/g' *.conf
```

### Check whether a service is running

```bash
systemctl is-active --quiet nginx && echo "Running" || echo "Not running"
```

### Check disk usage and alert

```bash
usage=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
[ "$usage" -ge 80 ] && echo "ALERT: Disk usage is ${usage}%"
```

### Find errors in a log in real time

```bash
tail -f app.log | grep -iE "error|critical|failed"
```

### Count ERROR messages

```bash
grep -ci "error" app.log
```

### Find large files

```bash
find /var/log -type f -size +100M -ls
```

---

## 7. Error Handling and Debugging

### Exit Codes

Every command returns an exit status.

```bash
some_command
echo "$?"

exit 0   # Success
exit 1   # Failure
```

### set -e

Stop the script when a command fails.

```bash
set -e
```

### set -u

Treat unset variables as errors.

```bash
set -u
```

### pipefail

Makes a pipeline fail if any command in the pipeline fails.

```bash
set -o pipefail
```

### Strict Mode

Common combination:

```bash
set -euo pipefail
```

### set -x

Print commands as Bash executes them — useful for debugging.

```bash
set -x
echo "Debugging"
set +x
```

### trap

Run cleanup code when the script exits.

```bash
cleanup() {
    echo "Cleaning up..."
}

trap cleanup EXIT
```

Useful for temporary files, locks, and cleanup tasks.

---

## 8. Bash Patterns Worth Remembering

### Check Arguments

```bash
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <file>"
    exit 1
fi
```

### Check File Before Using It

```bash
if [ ! -f "$1" ]; then
    echo "File not found: $1"
    exit 1
fi
```

### Store Command Output

```bash
date_now=$(date)
echo "$date_now"
```

### Capture Exit Status

```bash
command
status=$?

if [ "$status" -eq 0 ]; then
    echo "Success"
else
    echo "Failed"
fi
```

### Redirect Output

```bash
command > output.log       # stdout
command >> output.log      # append stdout
command 2> error.log       # stderr
command > output.log 2>&1  # stdout + stderr
```

### Pipe Commands

```bash
cat app.log | grep -i "error" | wc -l
```

---

## Quick Mental Model

When writing a Bash automation script, think:

```text
INPUT
  ↓
VALIDATE
  ↓
PROCESS
  ↓
CHECK ERRORS
  ↓
LOG / OUTPUT
  ↓
CLEAN UP
```

A practical DevOps script often looks like:

```bash
#!/bin/bash
set -euo pipefail

# 1. Validate input
# 2. Run commands
# 3. Check/process output
# 4. Handle errors
# 5. Clean up
```

---

## Most Important Commands to Remember

```text
Variables       → $VAR, "$VAR"
Arguments       → $0 $1 $# "$@"
Conditions       → [ ... ]
Arithmetic       → (( ... ))
Loops            → for / while / until
Functions        → name() { ... }
Search           → grep
Columns          → awk
Replace          → sed
Extract          → cut
Sort             → sort
Deduplicate      → uniq
Transform        → tr
Count            → wc
View logs        → head / tail
Find files       → find
Pipes            → |
Exit status      → $?
Debugging        → set -x
Strict mode      → set -euo pipefail
Cleanup          → trap
```

---

## Day 21 Checklist

- [ ] Review this cheat sheet before writing a Bash script.
- [ ] Practice one command from each section.
- [ ] Keep improving the sheet with commands you actually use.
