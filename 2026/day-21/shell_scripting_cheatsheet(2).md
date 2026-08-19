# Shell Scripting Cheat Sheet

Quick reference for Bash scripting and DevOps automation.

## Quick Reference Table

| Topic | Key Syntax | Example |
|---|---|---|
| Variable | `VAR="value"` | `NAME="DevOps"` |
| Argument | `$1`, `$2` | `./script.sh arg1 arg2` |
| If | `if [ condition ]; then` | `if [ -f file ]; then` |
| For loop | `for i in list; do` | `for i in 1 2 3; do` |
| Function | `name() { ... }` | `greet() { echo "Hi"; }` |
| Grep | `grep pattern file` | `grep -i "error" log.txt` |
| Awk | `awk '{print $1}' file` | `awk -F: '{print $1}' /etc/passwd` |
| Sed | `sed 's/old/new/g' file` | `sed -i 's/foo/bar/g' config.txt` |

---

# Task 1 — Basics

## 1. Shebang

Tells the system which interpreter should execute the script.

```bash
#!/bin/bash
```

## 2. Running a Script

```bash
chmod +x script.sh
./script.sh

# Or run directly with Bash
bash script.sh
```

`./script.sh` needs execute permission; `bash script.sh` does not.

## 3. Comments

```bash
# Single-line comment

echo "Hello"  # Inline comment
```

## 4. Variables and Quoting

Declare variables without spaces around `=`.

```bash
name="Hello World"
echo "$name"
```

| Syntax | Meaning |
|---|---|
| `$VAR` | Unquoted; can undergo word splitting and globbing |
| `"$VAR"` | Expands the variable while preserving spaces |
| `'$VAR'` | Treats `$VAR` literally |

**Best practice:** Prefer `"$VAR"` when using variables.

```bash
greeting="Hello World"

echo $greeting
echo "$greeting"
echo '$greeting'
```

## 5. Reading User Input — `read`

```bash
read -p "Enter your name: " name
echo "Hello, $name!"
```

Multiple variables can receive space-separated input:

```bash
read -p "Enter first and last name: " first last
echo "First: $first"
echo "Last: $last"
```

## 6. Command-Line Arguments

If running:

```bash
./script.sh file.txt backup/
```

| Variable | Meaning |
|---|---|
| `$0` | Script name |
| `$1` | First argument |
| `$2` | Second argument |
| `$#` | Number of arguments |
| `$@` | All arguments |
| `$?` | Exit status of the previous command |

```bash
echo "Script: $0"
echo "First: $1"
echo "Arguments: $#"

for arg in "$@"; do
    echo "$arg"
done
```

`"$@"` preserves each argument separately, including arguments containing spaces.

---

# Task 2 — Operators and Conditionals

## 1. String Comparisons

```bash
[ "$name" = "admin" ]     # Equal
[ "$name" != "admin" ]    # Not equal
[ -z "$name" ]             # Empty
[ -n "$name" ]             # Not empty
```

## 2. Integer Comparisons

| Operator | Meaning |
|---|---|
| `-eq` | Equal |
| `-ne` | Not equal |
| `-lt` | Less than |
| `-gt` | Greater than |
| `-le` | Less than or equal |
| `-ge` | Greater than or equal |

```bash
if [ "$age" -ge 18 ]; then
    echo "Adult"
fi
```

## 3. File Test Operators

| Operator | Checks |
|---|---|
| `-f` | Regular file |
| `-d` | Directory |
| `-e` | Exists |
| `-r` | Readable |
| `-w` | Writable |
| `-x` | Executable |
| `-s` | Exists and is not empty |

```bash
if [ -f "$file" ]; then
    echo "File exists"
fi
```

## 4. if / elif / else

```bash
if [ "$status" = "running" ]; then
    echo "Running"
elif [ "$status" = "stopped" ]; then
    echo "Stopped"
else
    echo "Unknown"
fi
```

## 5. Logical Operators

```bash
command1 && command2    # Run command2 if command1 succeeds
command1 || command2    # Run command2 if command1 fails
! command               # Reverse the result
```

With conditions:

```bash
if [ -f "$file" ] && [ -r "$file" ]; then
    echo "File exists and is readable"
fi
```

## 6. case

Useful when one value has multiple possible options.

```bash
case "$1" in
    start)
        echo "Starting"
        ;;
    stop)
        echo "Stopping"
        ;;
    restart)
        echo "Restarting"
        ;;
    *)
        echo "Usage: $0 {start|stop|restart}"
        ;;
esac
```

---

# Task 3 — Loops

## 1. for Loop — List-Based

```bash
for server in web1 web2 web3; do
    echo "Checking $server"
done
```

## for Loop — C-Style

Use `(( ))` for initialization, condition, and increment.

```bash
for (( i=1; i<=5; i++ )); do
    echo "$i"
done
```

## 2. while Loop

Runs while the condition remains true.

```bash
count=1

while [ "$count" -le 5 ]; do
    echo "$count"
    ((count++))
done
```

Reading a file line-by-line:

```bash
while read -r line; do
    echo "Processing: $line"
done < users.txt
```

`-r` prevents backslashes from being interpreted as escape characters.

## 3. until Loop

Runs while the condition is false and stops when it becomes true.

```bash
until [ -f "report.txt" ]; do
    echo "Waiting for report..."
    sleep 2
done
```

## 4. Loop Control

```bash
break       # Exit the loop completely
continue    # Skip the current iteration
```

Example:

```bash
for i in {1..5}; do
    if [ "$i" -eq 3 ]; then
        continue
    fi
    echo "$i"
done
```

## 5. Looping Over Files

```bash
for file in *.log; do
    [ -f "$file" ] || continue
    echo "Processing $file"
done
```

The `-f` check safely handles the case where no matching files exist.

## 6. Looping Over Command Output

```bash
while read -r line; do
    echo "Processing: $line"
done < <(command)
```

`while read -r` processes command output line-by-line without breaking lines containing spaces.

---

# Task 4 — Functions

## 1. Define a Function

```bash
greet() {
    echo "Hello!"
}
```

## 2. Call a Function

```bash
greet
```

## 3. Pass Arguments

Function arguments use `$1`, `$2`, etc.

```bash
greet() {
    echo "Hello, $1"
}

greet "Snigdha"
```

## 4. `return` vs `echo`

`return` gives a function an exit status; `echo` can output actual data.

```bash
check_file() {
    [ -f "$1" ]
}

if check_file "app.log"; then
    echo "File exists"
fi
```

```bash
get_directory() {
    echo "/var/backups"
}

directory=$(get_directory)
```

## 5. Local Variables

`local` keeps a variable limited to the function.

```bash
backup() {
    local backup_dir="/var/backups"
    echo "$backup_dir"
}
```

---

# Task 5 — Text Processing Commands

## 1. grep — Search

```bash
grep "ERROR" app.log
grep -i "error" app.log
grep -r "ERROR" /var/log
grep -c "ERROR" app.log
grep -n "ERROR" app.log
grep -v "INFO" app.log
grep -E "ERROR|CRITICAL" app.log
```

- `-i` ignore case
- `-r` recursive
- `-c` count matches
- `-n` line numbers
- `-v` invert/exclude
- `-E` extended regular expressions

## 2. awk — Columns and Patterns

```bash
awk '{print $1}' file.txt
awk -F: '{print $1}' /etc/passwd
awk '$3 > 80 {print $1, $3}' data.txt
```

- `$1`, `$2` = fields
- `$0` = complete line
- `-F` = field separator

`BEGIN` runs before input; `END` runs after input.

```bash
awk 'BEGIN {print "START"} {print $1} END {print "DONE"}' file.txt
```

## 3. sed — Modify Text

```bash
sed 's/old/new/g' file.txt
sed '3d' file.txt
sed '/^#/d' config.txt
sed -i 's/foo/bar/g' config.txt
```

- `s` = substitute
- `d` = delete
- `-i` = edit file in place

## 4. cut — Extract Fields

```bash
cut -d "," -f 1 users.csv
cut -d ":" -f 1,5 /etc/passwd
```

- `-d` = delimiter
- `-f` = field

## 5. sort

```bash
sort names.txt       # Alphabetical
sort -n numbers.txt  # Numerical
sort -r names.txt    # Reverse
sort -u names.txt    # Unique
```

## 6. uniq

Removes/counts adjacent duplicate lines.

```bash
sort names.txt | uniq
sort access.log | uniq -c
```

`-c` counts occurrences.

## 7. tr

Translate or delete characters.

```bash
echo "hello" | tr 'a-z' 'A-Z'
echo "server123" | tr -d '0-9'
```

## 8. wc

```bash
wc -l app.log   # Lines
wc -w app.log   # Words
wc -c app.log   # Characters/bytes
```

## 9. head / tail

```bash
head -n 5 app.log
tail -n 20 app.log
tail -f app.log
```

`tail -f` follows a log as new lines are added.

---

# Task 6 — Useful Patterns and One-Liners

## Find files older than N days

```bash
find /var/log -type f -mtime +7
```

Delete after verifying the results:

```bash
find /var/log -type f -mtime +7 -delete
```

## Count lines in all `.log` files

```bash
wc -l *.log
```

## Replace a string across multiple files

```bash
sed -i 's/old_value/new_value/g' *.conf
```

## Check if a service is running

```bash
systemctl is-active --quiet nginx && echo "Running" || echo "Not running"
```

## Monitor disk usage with an alert

```bash
usage=$(df / | awk 'NR==2 {print $5}' | tr -d '%')

if [ "$usage" -ge 80 ]; then
    echo "ALERT: Disk usage is ${usage}%"
fi
```

## Tail a log and filter errors in real time

```bash
tail -f app.log | grep -iE "error|critical|failed"
```

## Find the top 5 IP addresses in an access log

```bash
awk '{print $1}' access.log | sort | uniq -c | sort -rn | head -n 5
```

---

# Task 7 — Error Handling and Debugging

## 1. Exit Codes

`$?` contains the exit status of the previous command.

```bash
command
echo "$?"

exit 0    # Success
exit 1    # Failure
```

Generally:

```text
0     → success
non-0 → failure
```

## 2. set -e

Exit when a command fails.

```bash
set -e
```

## 3. set -u

Treat unset variables as errors.

```bash
set -u
```

## 4. set -o pipefail

Makes a pipeline fail if any command in the pipeline fails.

```bash
set -o pipefail
```

## 5. set -x

Print commands as Bash executes them for debugging.

```bash
set -x
echo "Debugging"
set +x
```

Or:

```bash
bash -x script.sh
```

## 6. trap

Run cleanup code when the script exits.

```bash
cleanup() {
    rm -f /tmp/temp_file
}

trap cleanup EXIT
```

Common pattern:

```bash
tmp_file=$(mktemp)

cleanup() {
    rm -f "$tmp_file"
}

trap cleanup EXIT
```

---

# Task 8 — Quick DevOps Patterns

These combine the concepts above into patterns you will commonly use.

## Validate Required Arguments

```bash
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <file>"
    exit 1
fi
```

## Validate a File

```bash
if [ ! -f "$1" ]; then
    echo "File not found: $1"
    exit 1
fi
```

## Capture Command Output

```bash
result=$(command)
echo "$result"
```

## Capture Exit Status

```bash
command
status=$?

if [ "$status" -ne 0 ]; then
    echo "Command failed"
fi
```

## Common Script Header

```bash
#!/bin/bash
set -euo pipefail
```

---

# Most-Used Commands at a Glance

```text
Variables       → VAR="value", "$VAR"
Arguments       → $0 $1 $# "$@"
Conditions      → [ ... ]
Decisions       → if / elif / else / case
Loops           → for / while / until
Functions       → name() { ... }
Search          → grep
Columns         → awk
Edit/replace    → sed
Extract         → cut
Sort            → sort
Deduplicate     → uniq
Transform       → tr
Count           → wc
View logs       → head / tail
Find files      → find
Pipe            → |
Redirect        → > >> 2>
Command output  → $(...)
Exit status     → $?
Error handling  → set -euo pipefail
Debugging       → set -x
Cleanup         → trap
```
