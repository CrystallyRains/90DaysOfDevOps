# Day 17 – Shell Scripting: Loops, Arguments & Error Handling

## Objective

The goal of Day 17 was to take Shell Scripting a step further by learning how to:

* Use `for` and `while` loops
* Work with command-line arguments
* Use Bash arrays
* Automate package installation
* Handle errors using `set -e` and `||`
* Check whether a script is being run as root

---

# 1. For Loop

A `for` loop is useful when we want to repeat an action for every item in a list.

## `for_loop.sh`

```bash
#!/bin/bash

fruits=("Apple" "Mango" "Banana" "Cherry" "Papaya")

for i in "${fruits[@]}"
do
    echo -e "\n$i"
done
```

### Output

```text
Apple
Mango
Banana
Cherry
Papaya
```

### How it works

First, an array is created:

```bash
fruits=("Apple" "Mango" "Banana" "Cherry" "Papaya")
```

The loop then goes through every item:

```bash
for i in "${fruits[@]}"
```

`${fruits[@]}` represents all the elements of the array.

---

# 2. Counting with a For Loop

The task was to print numbers from 1 to 10.

I also added an **even/odd check** to practice arithmetic operations.

## `count.sh`

```bash
#!/bin/bash

for i in {1..10}
do
    {
        if [ $((i%2)) -eq 0 ]; then
            echo "$i is even"
        else
            echo "$i is odd"
        fi
    }
done
```

### Output

```text
1 is odd
2 is even
3 is odd
4 is even
5 is odd
6 is even
7 is odd
8 is even
9 is odd
10 is even
```

### Arithmetic expansion

This part:

```bash
$((i%2))
```

performs arithmetic calculation.

The `%` operator gives the **remainder**.

For example:

```text
4 % 2 = 0
5 % 2 = 1
```

Therefore:

```text
remainder = 0 → even
remainder = 1 → odd
```

---

# 3. While Loop

A `while` loop continues running as long as its condition is true.

## `countdown.sh`

```bash
#!/bin/bash

read -p "Enter a number" num

while [ "$num" -ge 0 ]
do
    echo "$num"
    ((num--))
done

echo "Done!"
```

### Example Output

```text
Enter a number: 5
5
4
3
2
1
0
Done!
```

### How it works

The user enters a number:

```bash
read -p "Enter a number" num
```

The loop checks whether the number is greater than or equal to zero:

```bash
while [ "$num" -ge 0 ]
```

After every iteration:

```bash
((num--))
```

decreases the value by `1`.

Once the value becomes less than `0`, the loop stops.

---

# 4. Command-Line Arguments

Command-line arguments allow us to pass information to a script when running it.

For example:

```bash
./greet.sh Snigdha
```

Here, `Snigdha` is passed to the script as an argument.

## Important argument variables

| Variable | Meaning             |
| -------- | ------------------- |
| `$0`     | Script name         |
| `$1`     | First argument      |
| `$2`     | Second argument     |
| `$#`     | Number of arguments |
| `$@`     | All arguments       |

---

# 5. Greeting Using an Argument

## `greet.sh`

```bash
#!/bin/bash

if [ $# -gt 0 ]; then
    echo "Hello, $1!"
else
    echo "Usage: ./greet.sh <name>"
fi
```

### With an argument

Command:

```bash
./greet.sh Snigdha
```

Output:

```text
Hello, Snigdha!
```

### Without an argument

Command:

```bash
./greet.sh
```

Output:

```text
Usage: ./greet.sh <name>
```

### How it works

`$#` checks how many arguments were provided.

```bash
[ $# -gt 0 ]
```

means:

> Is the number of arguments greater than 0?

If yes, `$1` is used as the name.

---

# 6. Understanding `$#`, `$@`, and `$0`

## `args_demo.sh`

```bash
#!/bin/bash

echo "Total arguments: $#"
echo "All arguments: $@"
echo "Script name: $0"
```

### Example

Command:

```bash
./args_demo.sh Linux Docker Terraform
```

Output:

```text
Total arguments: 3
All arguments: Linux Docker Terraform
Script name: ./args_demo.sh
```

### What each variable gives us

```text
$# → 3
$@ → Linux Docker Terraform
$0 → ./args_demo.sh
```

These variables are especially useful when building scripts that accept dynamic input from the command line.

---

# 7. Installing Packages Using a Script

Shell scripts can also automate system administration tasks.

The goal here was to:

1. Check whether the script is running as root
2. Update the package index
3. Loop through a list of packages
4. Check whether each package is installed
5. Install missing packages
6. Display the package status

## `install_packages.sh`

```bash
#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "This script needs to be run as root. Please use 'sudo -i' or 'sudo su'."
    exit 1
fi

packg=(nginx curl wget)

apt-get update >/dev/null 2>&1

for i in "${packg[@]}"
do
    {
        if dpkg -s "$i" >/dev/null 2>&1; then
            echo "$i is installed"
        else
            apt-get install -y "$i"
        fi

        echo "--- Status for $i ---"
        dpkg -s "$i" | grep -E "Package:|Status:"
        echo ""
    }
done
```

---

## Checking for Root Privileges

The script first checks:

```bash
if [ "$EUID" -ne 0 ]; then
```

`EUID` represents the **effective user ID**.

For the root user:

```text
EUID = 0
```

Therefore:

```bash
"$EUID" -ne 0
```

means:

> The current user is not root.

If this condition is true, the script displays an error and exits:

```bash
exit 1
```

---

## Checking Whether a Package Is Installed

The script uses:

```bash
dpkg -s "$i"
```

to check the package status.

The output is redirected:

```bash
>/dev/null 2>&1
```

This hides both:

* Standard output
* Error output

The command's exit status is then used by the `if` statement.

```bash
if dpkg -s "$i" >/dev/null 2>&1; then
```

If the package is installed, the command succeeds and the `then` block runs.

Otherwise, the `else` block installs the package:

```bash
apt-get install -y "$i"
```

---

# 8. Error Handling with `set -e`

The `set -e` option tells Bash to exit when a command fails, unless that failure is being explicitly handled by a construct such as `||`.

## `safe_script.sh`

```bash
#!/bin/bash

set -e

mkdir /tmp/devops-test || echo "Directory already exists"
cd /tmp/devops-test || echo "Can't change to this directory"
touch demo_file.txt || echo "file already exists"
```

### What the script does

First:

```bash
set -e
```

enables exit-on-error behavior.

Then it creates a directory:

```bash
mkdir /tmp/devops-test
```

If the directory already exists, the command fails, but `||` handles that failure:

```bash
mkdir /tmp/devops-test || echo "Directory already exists"
```

The same concept is used with `cd` and `touch`.

---

# 9. Understanding `||`

The `||` operator means:

> Run the command on the right if the command on the left fails.

For example:

```bash
mkdir /tmp/devops-test || echo "Directory already exists"
```

The flow is:

```text
mkdir succeeds
      ↓
   Stop here

mkdir fails
      ↓
echo "Directory already exists"
```

This allows us to handle expected failures instead of letting the script stop without explanation.

---

# Key Learnings

### 1. Loops reduce repetitive work

`for` and `while` loops allow us to repeat commands automatically.

For example, instead of writing separate commands for three packages, a loop can process all of them:

```bash
for i in "${packg[@]}"
do
    ...
done
```

This becomes especially useful in automation.

### 2. Arguments make scripts reusable

Using:

```bash
$1
$#
$@
$0
```

allows scripts to accept different inputs without modifying the script itself.

For example:

```bash
./greet.sh Snigdha
```

and:

```bash
./greet.sh Shubham
```

can use the same script with different inputs.

### 3. Error handling makes scripts safer

Using:

```bash
set -e
```

and:

```bash
command || echo "Error message"
```

helps scripts respond properly when something goes wrong.

This is important when scripts are used for automation because a failed command can otherwise lead to unexpected results.

---

# Commands and Concepts Practiced

```bash
for item in list
do
    ...
done
```

```bash
while [ condition ]
do
    ...
done
```

```bash
$1
$#
$@
$0
```

```bash
$((expression))
```

```bash
set -e
```

```bash
command || echo "Error"
```

```bash
dpkg -s package
```

```bash
apt-get update
```

```bash
apt-get install -y package
```

```bash
exit 1
```

---

# Day 17 Summary

Day 17 moved beyond basic shell commands and introduced the building blocks needed for writing more useful automation scripts.

I practiced **loops, arrays, command-line arguments, package automation, root privilege checks, and basic error handling**.

These concepts make shell scripts more flexible, reusable, and useful for DevOps automation.
