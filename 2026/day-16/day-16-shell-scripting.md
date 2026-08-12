# Day 16 – Shell Scripting Basics

## Objective

The goal of Day 16 was to understand the basics of **Shell Scripting** and learn how scripts can automate simple tasks.

The main concepts covered were:

* Shebang
* Variables
* `echo`
* `read`
* `if`, `elif`, and `else`
* File checking with `-f`
* Basic service status checking

---

# 1. Shebang and My First Script

The **shebang** tells the system which interpreter should be used to execute the script.

For Bash scripts, we commonly use:

```bash
#!/bin/bash
```

### `hello.sh`

```bash
#!/bin/bash

echo "Hello, DevOps!"
```

### Output

```text
Hello, DevOps!
```

The script was made executable using:

```bash
chmod +x hello.sh
```

and executed with:

```bash
./hello.sh
```

### Why is the shebang important?

The shebang tells the system that the script should be interpreted using **Bash**.

Without the shebang, running the script directly may cause the system to use a different shell or fail to interpret Bash-specific syntax correctly.

---

# 2. Variables

Variables are used to store values that can be reused inside a script.

### `variables.sh`

```bash
#!/bin/bash

name="Snigdha"
role="DevOps Engineer"

echo "Hello, I am $name, and I'm a $role"
```

### Output

```text
Hello, I am Snigdha, and I'm a DevOps Engineer
```

### Important point

There should be **no spaces around `=`** when assigning a variable.

Correct:

```bash
name="Snigdha"
```

Incorrect:

```bash
name = "Snigdha"
```

To use the value stored in a variable, `$` is used:

```bash
$name
$role
```

---

# 3. Single Quotes vs Double Quotes

Shell treats single and double quotes differently.

### Single quotes

```bash
role='$name is a DevOps Engineer'
```

With single quotes, `$name` is treated as literal text.

The value becomes:

```text
$name is a DevOps Engineer
```

### Double quotes

```bash
role="$name is a DevOps Engineer"
```

With double quotes, `$name` is expanded to its stored value.

For example:

```text
Snigdha is a DevOps Engineer
```

### Simple rule

* **Single quotes `' '`** → variables are not expanded
* **Double quotes `" "`** → variables are expanded

---

# 4. Taking User Input with `read`

The `read` command is used to take input from the user.

### `great.sh`

```bash
#!/bin/bash

echo "Today's date is $(date)"

read -p "Enter your name:" name
read -p "What is your favourite tool?" fvrt_tool

echo "Hello, $name, Your favourite tool is $fvrt_tool"
```

### Example Output

```text
Today's date is Wed Aug 12 09:00:00 IST 2026
Enter your name: Snigdha
What is your favourite tool? Terraform
Hello, Snigdha, Your favourite tool is Terraform
```

The input entered by the user is stored in variables:

```bash
name
fvrt_tool
```

The values can then be used with `$`:

```bash
$name
$fvrt_tool
```

---

# 5. If-Else Conditions

Conditional statements allow a script to make decisions based on a condition.

The basic structure is:

```bash
if [ condition ]; then
    # commands
elif [ condition ]; then
    # commands
else
    # commands
fi
```

`fi` marks the end of the `if` statement.

---

## Checking Whether a Number is Positive, Negative, or Zero

### `check_number.sh`

```bash
#!/bin/bash

read -p "Enter a number" num

if [ "$num" -gt 0 ]; then
    echo "Positive number"
elif [ "$num" -lt 0 ]; then
    echo "Negative number"
else
    echo "Zero"
fi
```

### Example Outputs

For:

```text
Enter a number: 10
```

Output:

```text
Positive number
```

For:

```text
Enter a number: -5
```

Output:

```text
Negative number
```

For:

```text
Enter a number: 0
```

Output:

```text
Zero
```

### Operators used

| Operator | Meaning      |
| -------- | ------------ |
| `-gt`    | Greater than |
| `-lt`    | Less than    |

This script uses three conditions:

```text
number > 0  → Positive
number < 0  → Negative
number = 0  → Zero
```

---

# 6. Checking Whether a File Exists

The `-f` test checks whether a path exists and is a **regular file**.

### `file_check.sh`

```bash
#!/bin/bash

read -p "Enter the filename:" file_name

if [ -f "$file_name" ]; then
    echo "File exists"
else
    echo "File doesn't exist"
fi
```

### Example Output

If the file exists:

```text
Enter the filename: notes.txt
File exists
```

If the file doesn't exist:

```text
Enter the filename: test.txt
File doesn't exist
```

The important condition is:

```bash
[ -f "$file_name" ]
```

This checks whether the file exists as a regular file.

---

# 7. Checking a Service Status

The next script combines:

* Variables
* `read`
* `if`
* `elif`
* `else`
* `systemctl`

### `server_check.sh`

```bash
#!/bin/bash

read -p "Enter a service name:" svc_name

read -p "Do you want to check the status of $svc_name?" value

if [ "$value" == "y" ]; then
    if systemctl is-active --quiet "$svc_name"; then
        echo "$svc_name is active"
    else
        echo "$svc_name is not active"
    fi
elif [ "$value" == "n" ]; then
    echo "Skipped"
else
    echo "Provide a valid input"
fi
```

### Example Output

```text
Enter a service name: nginx
Do you want to check the status of nginx? y
nginx is active
```

If the user enters `n`:

```text
Enter a service name: nginx
Do you want to check the status of nginx? n
Skipped
```

If an invalid input is provided:

```text
Provide a valid input
```

### How it works

First, the script asks for the service name:

```bash
read -p "Enter a service name:" svc_name
```

Then it asks whether the user wants to check the status:

```bash
read -p "Do you want to check the status of $svc_name?" value
```

If the answer is `y`, the script checks the service:

```bash
systemctl is-active --quiet "$svc_name"
```

If the service is active:

```text
nginx is active
```

Otherwise:

```text
nginx is not active
```

---

## Understanding Exit Status in `if`

While working on `server_check.sh`, I had a question:

> If `systemctl is-active --quiet "$svc_name"` returns a number such as `0`, `1`, `2`, or `3`, how does the `if` statement know whether the service is active? Are we checking whether the entire command is equal to `0`?

The answer is **no**. We don't have to manually check the returned number.

Every Linux command finishes with an **exit status** (also called a return code).

Bash uses this exit status to determine whether a command **succeeded or failed**.

### Exit status rules

* **`0`** → Success → Bash treats it as **true**
* **Any non-zero value** (`1`, `2`, `3`, etc.) → Failure → Bash treats it as **false**

So when we write:

```bash
if systemctl is-active --quiet "$svc_name"; then
    echo "$svc_name is active"
else
    echo "$svc_name is not active"
fi
```

Bash runs:

```bash
systemctl is-active --quiet "$svc_name"
```

and looks at the command's **exit status** automatically.

We don't need to write:

```bash
if [ $? -eq 0 ]; then
```

The `if` statement itself can directly evaluate the command.

### What happens internally?

Suppose the service is active:

```text
systemctl is-active --quiet nginx
        ↓
exit status = 0
        ↓
if sees success
        ↓
then block runs
```

If the service is not active:

```text
systemctl is-active --quiet nginx
        ↓
exit status = non-zero
        ↓
if sees failure
        ↓
else block runs
```

### Direct vs manual checking

You *could* write:

```bash
systemctl is-active --quiet "$svc_name"

if [ $? -eq 0 ]; then
    echo "$svc_name is active"
fi
```

Here, `$?` contains the exit status of the **immediately preceding command**.

But the direct approach is cleaner:

```bash
if systemctl is-active --quiet "$svc_name"; then
    echo "$svc_name is active"
else
    echo "$svc_name is not active"
fi
```

### Important takeaway

The `if` statement in Bash does **not only evaluate `[ conditions ]`.

It can directly evaluate a command:

```bash
if command; then
    # command succeeded
else
    # command failed
fi
```

The command's **exit status** is what determines which branch runs.

This is a very useful pattern in DevOps scripting because it allows commands to be used directly as conditions instead of manually checking their exit codes.

---

# Key Learnings

### 1. A shell script is a sequence of commands

Instead of typing commands manually every time, they can be saved in a script and executed together.

### 2. Variables and user input make scripts dynamic

Using variables and `read` allows a script to work with different values instead of using fixed values.

For example:

```bash
read -p "Enter your name:" name
```

allows the same script to work for different users.

### 3. Conditions allow scripts to make decisions

Using:

```bash
if
elif
else
```

allows a script to respond differently depending on the situation.

This is the foundation for building more useful automation scripts.

---

# Commands Practiced

```bash
chmod +x hello.sh
./hello.sh
```

```bash
echo "Hello, DevOps!"
```

```bash
read -p "Enter your name:" name
```

```bash
if [ condition ]; then
```

```bash
elif [ condition ]; then
```

```bash
else
```

```bash
fi
```

```bash
[ -f "$file_name" ]
```

```bash
systemctl is-active --quiet "$svc_name"
```

---

# Day 16 Summary

Day 16 introduced the building blocks of **Shell Scripting**.

I practiced creating executable Bash scripts, storing values in variables, accepting user input, using conditions, checking files, and checking service status.

These are simple concepts, but they form the foundation for writing more useful automation scripts in DevOps.
