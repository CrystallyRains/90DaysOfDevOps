# Day 38 - YAML Basics

## Goal

Learn the basic YAML syntax used in DevOps and CI/CD configuration files.

YAML is mainly about **key-value pairs, lists, nesting, and indentation**.

---

## Task 1: Key-Value Pairs

The basic YAML format is:

```yaml
key: value
```

Example:

```yaml
name: Snigdha
role: DevOps Engineer
experience_years: 4
learning: true
```

Each key has a value associated with it.

YAML can store different types of values, such as strings, numbers, and booleans.

```yaml
name: Snigdha
experience_years: 4
learning: true
```

Here, `Snigdha` is a string, `4` is a number, and `true` is a boolean.

**Remember:** `true` is a boolean, but `"true"` is a string because it is inside quotes.

---

## Task 2: Lists

A list is used when one key needs multiple values.

### Block Style

Each item is written on a separate line using `-`.

```yaml
tools:
  - GitHub
  - Shell Scripting
  - Docker
  - GitHub Actions
  - Linux
```

The `-` represents each item in the list.

### Inline Style

A list can also be written in one line using square brackets.

```yaml
hobbies: ["reading", "writing", "roaming"]
```

So, the two ways to write a YAML list are:

1. **Block style** using `-`
2. **Inline/flow style** using `[ ]`

---

## Task 3: Nested Objects

YAML uses **indentation to show relationships between keys**.

Example:

```yaml
server:
  name: mac
  ip: 10.0.0.1
  port: 80
```

Here, `name`, `ip`, and `port` are inside `server`.

We can also have multiple levels of nesting:

```yaml
database:
  host: 10.0.0.2
  name: mydb
  credentials:
    user: "${username}"
    password: "${password}"
```

The structure is:

```text
database
  ├── host
  ├── name
  └── credentials
        ├── user
        └── password
```

### Important

Indentation is not just formatting in YAML. **Indentation defines the structure.**

Use spaces for indentation. **Never use tabs.**

---

## Task 4: Multi-line Strings

YAML provides two useful ways to write multi-line values.

### `|` Block Style

The `|` symbol preserves line breaks.

```yaml
startup_script: |
  npm install
  npm run dev
```

The two commands remain on separate lines.

Use `|` when the line breaks are important, such as scripts or other multi-line content.

### `>` Fold Style

The `>` symbol folds multiple lines into a single line.

```yaml
another: >
  Select *
  FROM students
```

The content is treated as one continuous value rather than preserving the line break.

Use `>` when you want to make long content easier to read in YAML, but the line breaks themselves are not important.

**Easy way to remember:**

```text
|  = preserve newlines
>  = fold newlines
```

---

## Task 5: Validate YAML

YAML files can be validated before using them in automation or CI/CD.

I used `yamllint` to validate both files:

```bash
yamllint person.yml
yamllint server.yaml
```

Both files were valid YAML.

`yamllint` also showed a warning about the missing document start:

```yaml
---
```

This was a **warning, not a syntax error**.

I then intentionally changed the indentation in `server.yaml`. The validator reported a syntax error:

```text
syntax error: mapping values are not allowed here
```

After fixing the indentation, the YAML structure was valid again.

### Key lesson

A small indentation mistake can change the YAML structure or make the file invalid.

---

## Task 6: Spot the Difference

Correct:

```yaml
tools:
  - docker
  - kubernetes
```

Both list items have the same indentation.

Incorrect:

```yaml
tools:
- docker
  - kubernetes
```

The indentation of the two list items is different.

Since YAML uses indentation to understand structure, the second block is invalid.

---

## YAML Files Created

### `person.yml`

```yaml
name: Snigdha
role: DevOps Engineer
experience_years: 4
learning: true

tools:
  - GitHub
  - Shell Scripting
  - Docker
  - GitHub Actions
  - Linux

hobbies: ["reading", "writing", "roaming"]
```

### `server.yaml`

```yaml
server:
  name: mac
  ip: 10.0.0.1
  port: 80

database:
  host: 10.0.0.2
  name: mydb
  credentials:
    user: "${username}"
    password: "${password}"

startup_script: |
  npm install
  npm run dev

another: >
  Select *
  FROM students
```

---

## Key Takeaways

### 1. YAML is indentation-sensitive

```yaml
server:
  name: mac
```

The indentation tells YAML that `name` belongs to `server`.

### 2. YAML supports different data structures

```yaml
name: Snigdha

tools:
  - Docker
  - Linux

database:
  host: localhost
```

This shows a key-value pair, a list, and a nested object.

### 3. YAML must be validated

A YAML file can look correct to us but still contain an indentation or syntax problem. Tools such as `yamllint` help catch these issues before the YAML is used in CI/CD.

---

## Day 38 Aha Moment

**In YAML, indentation is part of the syntax.**

Unlike many programming languages where indentation is mainly for readability, YAML uses indentation to understand the actual structure of the configuration.
