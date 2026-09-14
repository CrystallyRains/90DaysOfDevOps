# Day 38 - YAML Basics

## What is YAML?

YAML is a human-readable format used to store configuration and define settings. It is commonly used in DevOps tools and CI/CD pipelines.

## Task 1: Key-Value Pairs

Basic YAML syntax:

```yaml
name: Snigdha
role: DevOps Engineer
experience_years: 4
learning: true
```

`key: value` is the basic structure.

`true` and `false` are boolean values.

## Task 2: Lists

### Block Style

```yaml
tools:
  - GitHub
  - Docker
  - Linux
```

### Inline Style

```yaml
hobbies: ["reading", "writing", "roaming"]
```

**Two ways to write lists:** block style using `-` and inline style using `[ ]`.

## Task 3: Nested Objects

Indentation is used to create nested structures.

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
```

Here, `credentials` is nested inside `database`, and `user` and `password` are nested inside `credentials`.

**Important:** YAML uses spaces for indentation. Do not use tabs.

## Task 4: Multi-line Strings

### `|` Preserve newlines

```yaml
startup_script: |
  npm install
  npm run dev
```

Use `|` when line breaks need to be preserved.

### `>` Fold into one line

```yaml
another: >
  Select *
  FROM students
```

Use `>` when line breaks are not important and the content can be treated as one line.

**Remember:**

```text
| = preserve newlines
> = fold newlines
```

## Task 5: YAML Validation

Used `yamllint` to validate the YAML files.

```bash
yamllint person.yml
yamllint server.yaml
```

Both files were valid. `yamllint` showed a warning about the missing `---` document start.

After intentionally breaking the indentation, `yamllint` reported a syntax error.

**Key point:** YAML indentation must be consistent.

## Task 6: Spot the Difference

Correct:

```yaml
tools:
  - docker
  - kubernetes
```

Incorrect:

```yaml
tools:
- docker
  - kubernetes
```

The list items do not have the same indentation.

## Key Takeaways

1. YAML uses `key: value` syntax.
2. **Indentation defines structure**, so use spaces and never tabs.
3. Lists can use block style or inline style.
4. `|` preserves newlines, while `>` folds them.
5. Validate YAML before using it in CI/CD.

## Files

* `person.yml`
* `server.yaml`
* `day-38-yaml.md`
