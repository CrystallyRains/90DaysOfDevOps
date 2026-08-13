# Day 18 – Shell Scripting: Functions & Intermediate Concepts

## Objective

The goal of Day 18 was to make shell scripts more **reusable, structured, and safer**.

The main concepts practiced were:

* Bash functions
* Function arguments
* Function organization using `main`
* Local variables
* Strict mode with `set -euo pipefail`
* Command substitution
* Building a system information script

---

# Task 1 – Basic Functions

## 1. Greeting Function

Created `functions.sh` with a function that accepts a name as an argument.

```bash
#!/bin/bash

function_greet()
{
    name=$1
    echo "Hello, $1"
}

function_greet Snigdha
```

### Output

```text
Hello, Snigdha
```

Here, `$1` represents the first argument passed to the function.

For example:

```bash
function_greet Snigdha
```

passes `Snigdha` as `$1`.

---

## 2. Addition Function

The same script also contains an `add` function:

```bash
add()
{
    addition=$(($1+$2))
    echo "Addition is: $addition"
}

add 5 7
```

### Output

```text
Addition is: 12
```

The function receives two arguments:

* `$1` → `5`
* `$2` → `7`

The result is stored in the `addition` variable.

---

# Task 2 – Disk and Memory Check Functions

Created `disk_check.sh` using separate functions for disk and memory checks.

```bash
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
```

The script separates each check into its own function.

### Structure

```text
main()
 ├── check_memory()
 └── check_disk()
```

This makes the script easier to read and modify.

For example, another monitoring function could be added later without putting everything inside `main`.

---

# Task 3 – Strict Mode

Strict mode was practiced using:

```bash
set -euo pipefail
```

This combines three different Bash options.

## `set -e`

Stops the script when a command fails.

Example:

```bash
cat /path/to/non_existent_file.txt
```

Since the file does not exist, the command returns a non-zero exit status and the script stops.

---

## `set -u`

Treats the use of an undefined variable as an error.

For example:

```bash
echo "$name"
```

If `name` has not been defined, Bash reports an error instead of silently treating it as an empty value.

---

## `set -o pipefail`

Normally, a pipeline can return the exit status of its last command.

With `pipefail`, the pipeline fails if one of the commands inside it fails.

Example:

```bash
cat missing_file.txt | grep something
```

If `cat` fails, `pipefail` allows that failure to affect the status of the entire pipeline.

---

## Strict Mode Summary

| Option            | Purpose                             |
| ----------------- | ----------------------------------- |
| `set -e`          | Exit when a command fails           |
| `set -u`          | Treat undefined variables as errors |
| `set -o pipefail` | Detect failures inside pipelines    |

Together:

```bash
set -euo pipefail
```

make scripts more predictable and safer, especially when they are being used for automation.

---

# Task 4 – Local Variables

Created `local_demo.sh` to understand the difference between local and regular variables.

```bash
#!/bin/bash

name=$1

localf()
{
    local name="Snigs"
    echo "Local name is: $name"
}

regularf()
{
    name="Hacker"
    echo "[Inside regularf] name is: $name"
}

echo "before function"
localf
regularf

echo "after function"
echo "My name is $name"
```

## What this demonstrates

Inside `localf()`:

```bash
local name="Snigs"
```

creates a variable that belongs only to that function.

Changing it does not change the variable outside the function.

However, `regularf()` uses:

```bash
name="Hacker"
```

without the `local` keyword.

Therefore, it modifies the existing variable in the surrounding shell context.

### Key difference

```text
local variable
      ↓
exists only inside the function

regular variable
      ↓
can affect the variable outside the function
```

Using `local` helps prevent accidental changes to variables elsewhere in a script.

---

# Task 5 – System Information Reporter

Created `system_info.sh` as an intermediate Bash script using multiple functions.

```bash
#!/bin/bash

set -euo pipefail

host_os()
{
    echo "Hostname: $(hostname)"
    echo "OS: $(uname -s)"
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
```

## Functions used

### `host_os`

Displays:

* Hostname
* Operating system

Commands used:

```bash
hostname
uname -s
```

---

### `get_uptime`

Displays how long the system has been running.

```bash
uptime
```

---

### `disk_usage`

Displays disk usage information and sorts the results.

```bash
df -h | sort -hr | head -n 5
```

This combines multiple commands through a pipeline.

---

### `memory_usage`

Displays available and used memory:

```bash
free -h
```

---

### `top_cpu`

Displays processes sorted by CPU usage:

```bash
ps -eo pid,user,%cpu,comm --sort=-%cpu | head -n 6
```

This helps identify processes consuming the most CPU.

---

# Why Use a `main` Function?

Instead of running everything directly, the script uses:

```bash
main()
{
    host_os
    get_uptime
    disk_usage
    memory_usage
    top_cpu
}

main
```

This provides a clear entry point for the script.

The overall structure becomes:

```text
main
 │
 ├── host_os
 ├── get_uptime
 ├── disk_usage
 ├── memory_usage
 └── top_cpu
```

This makes larger shell scripts easier to understand and maintain.

---

# Key Takeaways

### 1. Functions make scripts reusable

Instead of repeating commands, related operations can be grouped into functions.

```bash
check_disk()
{
    df -h /
}
```

The function can then be called whenever needed.

---

### 2. `local` prevents accidental variable changes

Variables inside functions should often be declared with `local` when they are only needed inside that function.

```bash
local name="Snigs"
```

This helps avoid unexpected changes to variables elsewhere in the script.

---

### 3. Strict mode makes scripts safer

```bash
set -euo pipefail
```

helps catch:

* Failed commands
* Undefined variables
* Failures hidden inside pipelines

This is especially useful when Bash scripts are used for automation.

---

# Day 18 Summary

Day 18 moved from simply writing Bash commands to **structuring scripts properly**.

I practiced:

* Creating and calling functions
* Passing arguments to functions
* Using local variables
* Understanding Bash variable scope
* Using `set -euo pipefail`
* Combining commands with pipelines
* Building a reusable system information reporter

The biggest takeaway was that Bash scripts become much easier to maintain when they are broken into **small functions with clear responsibilities**.
