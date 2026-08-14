# Day 19 - Shell Scripting Projects

## Objective

Today was about putting the Bash concepts from the previous days together into practical scripts.

### Projects

- **Backup Script** → creates a compressed backup and removes old backups.
- **Log Rotation Script** → compresses old logs and deletes older compressed logs.

The goal is not to memorize the scripts. The important part is understanding the **flow** and the Bash concepts being used.

---

# Project 1 — Backup Script

## What the script does

```text
Take source directory + backup destination
            ↓
Check the arguments
            ↓
Check source directory exists
            ↓
Create destination if needed
            ↓
Create dated .tar.gz backup
            ↓
Verify backup
            ↓
Show name + size
            ↓
Delete backups older than 14 days
```

### Running it

```bash
./backup.sh fake_logs fresh_logs
```

The script expects two positional arguments:

```bash
$1 → source directory
$2 → backup destination
```

`$0` represents the script itself.

For example:

```bash
./backup.sh fake_logs fresh_logs
```

means:

```text
$1 = fake_logs
$2 = fresh_logs
```

---

## Important Bash concepts used

### Argument validation

```bash
if [ -z "$1" ] || [ -z "$2" ]; then
```

`-z` checks whether a value is empty.

This prevents the script from running without the required inputs.

---

### Directory check

```bash
if [ ! -d "$source_dir" ]; then
```

`-d` checks whether the path is a directory.

`!` means NOT.

So this checks:

> Does the source directory NOT exist?

---

### Creating the destination

```bash
mkdir -p "$backup_dir"
```

`mkdir` creates a directory.

`-p` means the command won't fail just because the directory already exists.

---

## Creating the backup

```bash
timestamp=$(date +%Y-%m-%d)
archive_name="backup-${timestamp}.tar.gz"
```

`date` generates the current date.

`$(...)` is **command substitution** — it puts the output of a command into a variable.

So the result can be:

```text
backup-2026-08-14.tar.gz
```

---

### `tar`

```bash
tar -czf "$archive_path" ...
```

The important options are:

```text
-c → create archive
-z → gzip compression
-f → specify archive filename
```

So `tar -czf` creates a compressed `.tar.gz` archive.

The script also uses:

```bash
dirname
basename
```

to separate the parent directory from the directory being backed up.

---

## Checking whether the backup worked

```bash
if [ $? -eq 0 ] && [ -f "$archive_path" ]; then
```

Two useful concepts here:

```bash
$?
```

→ exit status of the previous command.

Usually:

```text
0 = success
non-zero = error
```

and:

```bash
-f
```

→ checks whether a regular file exists.

So the script is checking both:

> Did `tar` succeed, and was the archive actually created?

---

## Checking archive size

```bash
du -sh "$archive_path"
```

```text
-s → show total
-h → human-readable
```

The script then uses:

```bash
| cut -f1
```

The pipe `|` sends the output of one command into another.

`cut -f1` keeps the first field, giving a clean size such as:

```text
4.0K
```

---

## Cleaning old backups

```bash
find "$backup_dir" -type f -name "backup-*.tar.gz" -mtime +14 -exec rm {} \;
```

This is the main cleanup command.

The useful pieces to remember:

```text
-type f
→ files only

-name "backup-*.tar.gz"
→ matching backup files

-mtime +14
→ older than 14 days

-exec rm {} \;
→ run rm on each matching file
```

This is a good example of how `find` can be used for automation.

---

# Project 2 — Log Rotation Script

## What the script does

```text
Find .log files older than 7 days
            ↓
Compress them with gzip
            ↓
Count compressed files
            ↓
Find .gz files older than 30 days
            ↓
Delete them
            ↓
Count deleted files
```

### Running it

```bash
./log_rotate.sh fake_logs
```

Here:

```text
$1 = fake_logs
```

---

## Checking the directory

```bash
if [ ! -d "$1" ]; then
```

Same directory check as the backup script.

If the directory doesn't exist, the script exits with:

```bash
exit 1
```

---

## Counters

```bash
comp=0
del=0
```

These variables keep track of how many files were processed.

```bash
((comp++))
```

increments the compression counter.

```bash
((del++))
```

increments the deletion counter.

---

## Finding old logs

```bash
find "$1" -type f -name "*.log" -mtime +7
```

This means:

> Find regular files ending in `.log` that are older than 7 days.

The result is processed by a `for` loop:

```bash
for file in $(find ...); do
    gzip "$file"
    ((comp++))
done
```

`gzip` compresses:

```text
app.log
```

into:

```text
app.log.gz
```

---

## Removing old compressed logs

```bash
find "$1" -type f -name "*.gz" -mtime +30
```

This finds compressed files older than 30 days.

Then:

```bash
rm "$file"
```

removes each one.

---

# Testing the Scripts

To create test files with specific timestamps:

```bash
touch -t 202608011200 fake_logs/old_app1.log
touch -t 202607251200 fake_logs/old_app2.log
```

`touch -t` lets us set a file's modification timestamp.

This is useful when testing commands such as:

```bash
-mtime +7
```

without actually waiting seven days.

After running:

```bash
./log_rotate.sh fake_logs
```

the result was:

```text
Total files compressed: 2
Total files deleted: 2
```

And the backup script successfully produced:

```text
Archive created successfully!
Archive Name: backup-2026-08-14.tar.gz
Archive Size: 4.0K
Cleaning up backups older than 14 days in fresh_logs...
Backup process complete.
```

---

# Commands & Concepts to Remember

| Command / Concept | What it does |
|---|---|
| `chmod +x` | Makes a script executable |
| `$1`, `$2` | Positional arguments |
| `$?` | Previous command's exit status |
| `-d` | Checks for a directory |
| `-f` | Checks for a regular file |
| `-z` | Checks whether a string is empty |
| `mkdir -p` | Creates a directory if needed |
| `tar -czf` | Creates a gzip-compressed archive |
| `gzip` | Compresses a file |
| `find` | Searches for files/directories |
| `-mtime` | Filters by modification age |
| `rm` | Deletes files |
| `du -sh` | Shows human-readable disk usage |
| `date` | Gets the date/time |
| `$()` | Command substitution |
| `\|` | Pipes output to another command |
| `((var++))` | Increments a variable |
| `touch -t` | Sets a specific file timestamp |

---

# Day 19 Takeaway

The bigger lesson today was **combining simple commands into automation**.

Instead of running:

```text
find
gzip
rm
tar
du
```

manually every time, Bash lets us turn the whole workflow into a reusable script.

These two projects are small, but the same ideas are useful in real DevOps tasks such as:

- backups
- log management
- cleanup jobs
- scheduled maintenance
- disk-space management

The scripts are the practice. The **patterns behind them** are what are worth remembering.
