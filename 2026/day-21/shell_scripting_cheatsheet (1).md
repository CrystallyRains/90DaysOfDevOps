# Shell Scripting Cheat Sheet

My working reference for Bash. Written the way I actually use it: syntax first, one line of context, then a real example. If you read it top to bottom once, you should be able to write and debug a script without opening ten browser tabs.

Two rules I follow while writing scripts, and they show up all over this sheet:

1. Quote your variables. `"$VAR"`, not `$VAR`. Skipping quotes is the single most common bug in shell scripts.
2. Prefer `[[ ]]` over `[ ]` in Bash. It is safer with empty values and supports pattern matching.

---

## Quick Reference

| Topic | Key syntax | Example |
|---|---|---|
| Shebang | `#!/usr/bin/env bash` | first line of every script |
| Variable | `VAR="value"` | `NAME="DevOps"` |
| Use variable | `"$VAR"` | `echo "Hello $NAME"` |
| Arguments | `$1`, `$#`, `"$@"` | `./script.sh staging` |
| Exit status | `$?` | `grep -q x f; echo $?` |
| If | `if [[ cond ]]; then ... fi` | `if [[ -f "$f" ]]; then` |
| String empty | `-z` / `-n` | `[[ -z "$1" ]]` |
| Numbers | `-eq -ne -lt -gt -le -ge` | `[[ $count -gt 10 ]]` |
| For loop | `for i in list; do ... done` | `for f in *.log; do` |
| While | `while [[ cond ]]; do ... done` | `while read -r line; do` |
| Case | `case "$x" in p) ;; esac` | `case "$env" in prod) ...` |
| Function | `name() { ... }` | `log() { echo "[INFO] $*"; }` |
| Command output | `$(command)` | `now=$(date +%F)` |
| Arithmetic | `$(( ))` | `total=$(( a + b ))` |
| Default value | `${VAR:-default}` | `PORT="${PORT:-8080}"` |
| Grep | `grep pattern file` | `grep -i "error" app.log` |
| Awk | `awk '{print $1}' file` | `awk -F: '{print $1}' /etc/passwd` |
| Sed | `sed 's/old/new/g' file` | `sed -i 's/foo/bar/g' cfg.txt` |
| Safety header | `set -euo pipefail` | put it at the top |
| Debug | `bash -x script.sh` | traces every line |

---

## 1. Script Basics

### Shebang

Tells the kernel which interpreter runs the file. Without it, the script runs under whatever shell called it, which is how "works on my machine" bugs start.

```bash
#!/usr/bin/env bash    # portable, finds bash via PATH
#!/bin/bash            # fine on Linux, bash may live elsewhere on other systems
```

Note: on macOS, `/bin/bash` is an old 3.2 build, so newer syntax silently breaks. `env bash` picks up the Homebrew version.

### Running a script

```bash
chmod +x script.sh     # make it executable (one time)
./script.sh            # runs using the shebang
bash script.sh         # runs with bash, ignores the shebang, no chmod needed
source script.sh       # runs in your CURRENT shell, so variables persist
```

`./script.sh` starts a subshell. Any `cd` or variable inside it disappears when it ends. Use `source` when you want the changes to stick.

### Comments

```bash
# full line comment
echo "deploying"   # inline comment
```

There is no block comment in Bash. Comment each line, or wrap the block in `: <<'NOTE' ... NOTE`.

### Variables

```bash
NAME="DevOps"        # no spaces around =, this is not optional
echo "$NAME"         # DevOps
echo '$NAME'         # $NAME  (single quotes disable expansion)
echo "${NAME}Ninja"  # braces separate the name from the text next to it
readonly API="v1"    # cannot be reassigned
unset NAME           # remove it
```

Quoting, the short version:

| Form | Expands variables? | Use it when |
|---|---|---|
| `"$VAR"` | yes | almost always |
| `'$VAR'` | no | you want the literal text |
| `$VAR` | yes, then splits on spaces | rarely, and usually by accident |

Why it matters:

```bash
FILE="my report.txt"
rm $FILE     # tries to delete "my" and "report.txt"
rm "$FILE"   # correct
```

### Reading input

```bash
read -p "Environment: " ENV          # prompt and store
read -rp "Name: " NAME               # -r keeps backslashes literal
read -sp "Password: " PASS; echo     # -s hides typing
read -t 10 -p "Continue? " ANSWER    # times out after 10s
```

Use `-r` by default. Plain `read` eats backslashes, which mangles paths.

### Command line arguments

```bash
$0     # script name
$1 $2  # first, second argument
$#     # number of arguments
"$@"   # all arguments, each one kept separate  <-- use this
"$*"   # all arguments as one single string
$?     # exit status of the last command (0 = success)
$$     # PID of the current script
!!     # last command you ran (interactive shell)
```

A guard clause worth copying into every script:

```bash
if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <environment>" >&2
  exit 1
fi
ENV="$1"
```

---

## 2. Operators and Conditionals

### String comparison

```bash
[[ "$a" == "$b" ]]     # equal (= also works, == reads better)
[[ "$a" != "$b" ]]     # not equal
[[ -z "$a" ]]          # true if empty
[[ -n "$a" ]]          # true if not empty
[[ "$a" == err* ]]     # pattern match, works only inside [[ ]]
[[ "$a" =~ ^ERR[0-9]+$ ]]   # regex match, also [[ ]] only
```

### Integer comparison

```bash
[[ $x -eq $y ]]   # equal
[[ $x -ne $y ]]   # not equal
[[ $x -lt $y ]]   # less than
[[ $x -gt $y ]]   # greater than
[[ $x -le $y ]]   # less than or equal
[[ $x -ge $y ]]   # greater than or equal
(( x > y ))       # arithmetic form, reads more naturally for math
```

`-eq` is for numbers, `==` is for strings. `[[ "10" == "10.0" ]]` is false while `[[ 10 -eq 10 ]]` is true, and mixing them up produces bugs that only appear on certain inputs.

### File tests

```bash
[[ -e "$f" ]]   # exists (file or directory)
[[ -f "$f" ]]   # exists and is a regular file
[[ -d "$f" ]]   # is a directory
[[ -s "$f" ]]   # exists and is not empty
[[ -r "$f" ]]   # readable
[[ -w "$f" ]]   # writable
[[ -x "$f" ]]   # executable
[[ -L "$f" ]]   # is a symlink
[[ "$a" -nt "$b" ]]   # a is newer than b
```

### if / elif / else

```bash
if [[ $usage -ge 90 ]]; then
  echo "CRITICAL"
elif [[ $usage -ge 75 ]]; then
  echo "WARNING"
else
  echo "OK"
fi
```

The `;` before `then` matters. Without it, `then` has to go on its own line.

### Logical operators

```bash
[[ -f "$f" && -r "$f" ]]      # AND
[[ "$e" == dev || "$e" == qa ]]   # OR
[[ ! -d /var/log/app ]]       # NOT

mkdir -p /tmp/build && cd /tmp/build   # run second only if first succeeds
ping -c1 host >/dev/null || echo "unreachable"   # run second only if first fails
```

Careful with `cmd && a || b`. If `a` fails, `b` runs too, so it is not a real if/else. Use a proper `if` when the result matters.

### Case

Cleaner than a stack of elifs when you are matching one value against several patterns.

```bash
case "$1" in
  start)        echo "starting" ;;
  stop|halt)    echo "stopping" ;;      # multiple patterns
  restart)      echo "restarting" ;;
  *.log)        echo "that is a log file" ;;   # globs work
  *)            echo "Usage: $0 {start|stop|restart}"; exit 1 ;;
esac
```

Every branch ends with `;;`. The `*)` catch-all goes last.

---

## 3. Loops

### for

```bash
for env in dev qa prod; do          # list based
  echo "deploying to $env"
done

for i in {1..5}; do echo "$i"; done       # range
for i in {0..20..5}; do echo "$i"; done   # step of 5

for (( i=0; i<5; i++ )); do echo "$i"; done   # C style
```

### while

Runs while the condition is true. Good for counters, retries and waiting on something.

```bash
count=1
while [[ $count -le 3 ]]; do
  echo "attempt $count"
  ((count++))
done

until curl -sf http://localhost:8080/health; do   # until = while NOT
  echo "waiting for app..."
  sleep 2
done
```

### break and continue

```bash
for f in *.log; do
  [[ -s "$f" ]] || continue     # skip empty files, go to next
  grep -q "FATAL" "$f" && { echo "found in $f"; break; }   # stop entirely
done
```

`break 2` exits two levels of nested loops at once.

### Looping over files

```bash
for f in *.log; do
  echo "$f has $(wc -l < "$f") lines"
done
```

If no `.log` file exists, the loop still runs once with the literal string `*.log`. Guard it:

```bash
shopt -s nullglob        # unmatched globs expand to nothing
for f in *.log; do ...; done
```

### Looping over command output

```bash
while IFS= read -r line; do
  echo "Processing: $line"
done < servers.txt

ps aux | while IFS= read -r line; do echo "$line"; done   # from a pipe
```

`IFS=` keeps leading and trailing spaces, `-r` keeps backslashes. Do not use `for line in $(cat file)`, it splits on every space instead of every line.

---

## 4. Functions

### Define and call

```bash
greet() {
  echo "Hello, $1"
}

greet "DevOps"      # call it with a space, not parentheses
```

Define functions before you call them. Bash reads the file top to bottom.

### Arguments

Functions get their own `$1`, `$2`, `$@`, and `$#`, separate from the script's.

```bash
deploy() {
  local app="$1"
  local env="${2:-dev}"     # default if not passed
  echo "Deploying $app to $env"
}

deploy "api" "prod"
```

### return vs echo

This trips up almost everyone at the start.

```bash
is_running() {
  pgrep -x "$1" >/dev/null      # return sends back an EXIT CODE (0-255)
}
is_running nginx && echo "up"

get_timestamp() {
  echo "$(date +%F_%H-%M)"      # echo sends back a VALUE
}
stamp=$(get_timestamp)
```

`return` for success or failure, `echo` plus `$(...)` for data.

### local variables

```bash
counter() {
  local count=0        # visible only inside the function
  count=$((count + 1))
}
```

Without `local`, every variable is global and functions quietly overwrite each other. Make `local` a habit.

A logging helper worth stealing:

```bash
log()  { echo "[$(date +%T)] [INFO] $*"; }
warn() { echo "[$(date +%T)] [WARN] $*" >&2; }
die()  { echo "[$(date +%T)] [ERROR] $*" >&2; exit 1; }

log "starting deploy"
[[ -f config.yml ]] || die "config.yml missing"
```

---

## 5. Text Processing

This is where shell scripting pays for itself. Logs, CSVs, config files, all of it.

### grep, find the lines

```bash
grep "error" app.log          # matching lines
grep -i "error" app.log       # case insensitive
grep -r "TODO" ./src          # recursive through a directory
grep -c "404" access.log      # count of matching lines
grep -n "error" app.log       # show line numbers
grep -v "DEBUG" app.log       # invert, everything EXCEPT matches
grep -E "error|fatal" app.log # extended regex, multiple patterns
grep -l "nginx" *.conf        # just list filenames that match
grep -A3 -B3 "panic" app.log  # 3 lines after and before, great for stack traces
grep -q "ok" f && echo yes    # quiet, use in conditions
```

### awk, work with columns

Splits each line into fields (`$1`, `$2`, ...) where `$0` is the whole line.

```bash
awk '{print $1}' access.log                    # first column
awk '{print $1, $9}' access.log                # multiple columns
awk -F: '{print $1}' /etc/passwd                # custom separator
awk '$9 == 500 {print $7}' access.log           # filter, then print
awk '$5+0 > 80' df.txt                          # numeric compare, +0 strips "%"
awk '{sum+=$1} END {print sum}' nums.txt        # totals
awk 'BEGIN{print "Start"} {print} END{print NR" lines"}' f.txt
```

`NR` is the current line number, `NF` is the number of fields, so `$NF` is the last column.

### sed, edit the stream

```bash
sed 's/old/new/' f.txt        # replace first match per line
sed 's/old/new/g' f.txt       # replace all matches
sed -i 's/old/new/g' f.txt    # edit the file in place (GNU/Linux)
sed -i '' 's/old/new/g' f.txt # in place on macOS, note the empty ''
sed -n '5,10p' f.txt          # print only lines 5 to 10
sed '/^#/d' config.conf       # delete comment lines
sed '/^$/d' f.txt             # delete blank lines
sed 's|/old/path|/new/path|g' f.txt   # use | when the text has slashes
```

Always run it once without `-i` to see the output before you overwrite anything.

### cut, sort, uniq

```bash
cut -d: -f1 /etc/passwd       # field 1, colon delimited
cut -d, -f1,3 data.csv        # fields 1 and 3
cut -c1-10 f.txt              # by character position

sort f.txt                    # alphabetical
sort -n nums.txt              # numeric (10 after 9, not before it)
sort -nr nums.txt             # numeric, largest first
sort -u f.txt                 # sorted and deduplicated
sort -k2 -n data.txt          # sort by column 2
sort -t, -k3 -n data.csv      # column 3 of a CSV

uniq f.txt                    # remove ADJACENT duplicates only
sort f.txt | uniq             # the way you actually use it
sort f.txt | uniq -c          # count occurrences
sort f.txt | uniq -d          # show only duplicates
```

`uniq` only compares neighbouring lines, so it is nearly always preceded by `sort`.

### tr, wc, head, tail

```bash
tr 'a-z' 'A-Z' < f.txt        # uppercase
tr -d '\r' < f.txt            # strip Windows carriage returns
tr -s ' ' < f.txt             # squeeze repeated spaces into one
tr ' ' '\n' < f.txt           # split words onto separate lines

wc -l f.txt                   # line count
wc -w f.txt                   # word count
wc -c f.txt                   # bytes
wc -l < f.txt                 # count only, no filename in the output

head -20 f.txt                # first 20 lines
tail -20 f.txt                # last 20 lines
tail -n +50 f.txt             # from line 50 to the end
tail -f app.log               # follow live
tail -F app.log               # follow across log rotation
```

---

## 6. One Liners Worth Remembering

Delete log files older than 7 days:
```bash
find /var/log/app -name "*.log" -mtime +7 -delete
```

Count lines across every log file:
```bash
find . -name "*.log" | xargs wc -l | tail -1
```

Replace a string across many files at once:
```bash
grep -rl "old.api.com" . | xargs sed -i 's/old.api.com/new.api.com/g'
```

Check whether a service is up:
```bash
systemctl is-active --quiet nginx && echo "nginx up" || echo "nginx DOWN"
```

Alert on any partition above 80 percent:
```bash
df -h | awk 'NR>1 && $5+0 > 80 {print "HIGH: " $6 " at " $5}'
```

Watch a log for errors in real time:
```bash
tail -f app.log | grep --line-buffered -i "error"
```

`--line-buffered` is the part people miss. Without it, grep holds the output in a buffer and your terminal sits there looking frozen.

Top 10 IPs hitting your server:
```bash
awk '{print $1}' access.log | sort | uniq -c | sort -nr | head -10
```

Five heaviest processes by memory:
```bash
ps aux | sort -k4 -nr | head -5
```

Everything listening on a port:
```bash
ss -tulpn | grep LISTEN
```

Find the biggest directories under the current one:
```bash
du -sh ./* | sort -rh | head -10
```

Read a JSON field without a parser library:
```bash
curl -s https://api.example.com/status | grep -o '"state":"[^"]*"' | cut -d'"' -f4
```
Use `jq` when it is available. `jq -r '.state'` is shorter and does not break on formatting changes.

---

## 7. Error Handling and Debugging

### Exit codes

`0` means success. Anything from `1` to `255` means failure. This is the opposite of most programming languages, and it catches people out.

```bash
grep -q "error" app.log
echo $?          # 0 if found, 1 if not

exit 0           # finished fine
exit 1           # something went wrong
```

Check `$?` immediately. The next command overwrites it.

### The safety header

```bash
set -euo pipefail
```

Three settings that turn silent failures into loud ones:

| Flag | What it does | Why you want it |
|---|---|---|
| `set -e` | exit on any failed command | stops the script from carrying on with bad state |
| `set -u` | error on undefined variables | catches typos before they become `rm -rf /` |
| `set -o pipefail` | a pipeline fails if any stage fails | otherwise only the last command's status counts |

What `pipefail` fixes:

```bash
cat missing.txt | wc -l   # exit code 0, because wc succeeded
# with pipefail, this correctly reports failure
```

Where `set -e` does not save you: it is ignored inside `if` conditions, in `&&` and `||` chains, and in commands whose result you are already testing. So it is a safety net, not a guarantee. Keep checking things that matter.

When a command is allowed to fail:

```bash
grep "warn" app.log || true
```

### Debugging

```bash
set -x            # print every command as it runs
set +x            # turn it back off
bash -x script.sh # trace the whole run without editing the file
bash -n script.sh # syntax check, does not execute anything
```

Trace only the section you suspect:

```bash
set -x
risky_function
set +x
```

Also run `shellcheck script.sh`. It catches unquoted variables and bad comparisons before you ever run the script, and it is the fastest way to level up your Bash.

### trap, cleanup that always runs

```bash
cleanup() {
  rm -f /tmp/deploy.lock
  echo "cleaned up"
}
trap cleanup EXIT        # runs on normal exit, error exit, and Ctrl+C
trap 'echo interrupted' INT
```

Any script that creates a temp file, a lock file, or a background process should have a `trap`. It is what keeps a failed run from leaving a mess behind for the next one.

---

## 8. Mistakes That Cost Me Time

- `VAR = "value"` with spaces. Bash reads `VAR` as a command. It has to be `VAR="value"`.
- Unquoted `$VAR` anywhere a value can contain a space or be empty.
- `-eq` on strings and `==` on numbers.
- `for line in $(cat file)` instead of `while IFS= read -r line`.
- Running `sed -i` before checking the output once without `-i`.
- Expecting `cd` inside a script to change the directory of your terminal. It does not, unless you `source` it.
- `uniq` without `sort` in front of it.
- No shebang, so the script works for you and breaks for everyone else.

---

## Starter Template

Every script I write starts here.

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="/tmp/$(basename "$0").log"

log()  { echo "[$(date +'%F %T')] [INFO] $*" | tee -a "$LOG_FILE"; }
die()  { echo "[$(date +'%F %T')] [ERROR] $*" >&2; exit 1; }

cleanup() {
  log "cleaning up"
}
trap cleanup EXIT

usage() {
  echo "Usage: $0 <environment>"
  exit 1
}

main() {
  [[ $# -ge 1 ]] || usage
  local env="$1"

  log "starting run for $env"
  # your logic here
  log "done"
}

main "$@"
```

---

## Practice Prompts

Try these without looking anything up. If you can do all five, the sheet has done its job.

1. Print the 5 most frequent error messages in a log file.
2. Loop through every `.conf` file in a directory and back it up with a timestamp.
3. Write a function that takes a service name and returns success or failure based on whether it is running.
4. Alert when any disk partition crosses 85 percent.
5. Replace a config value across a directory tree, but print what would change before doing it.

---

Part of my #90DaysOfDevOps journey, Day 21.
`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`
