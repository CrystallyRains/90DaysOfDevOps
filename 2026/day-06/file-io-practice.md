# File Read/Write Practice

Day 06 of #90DaysOfDevOps.

```
touch notes.txt
```
Creates an empty file. If it already exists, this does nothing to it.

```
echo "Line 1" > notes.txt
```
`>` means overwrite. Writes the file fresh — anything that was in it
before is gone.

```
echo "Line 2" >> notes.txt
```
`>>` means append. Adds a new line at the end, doesn't touch what's
already there.

```
echo "Line 3" | tee -a notes.txt
```
`tee` writes to the file and prints it on screen at the same time.
`-a` makes it append instead of overwrite, so it behaves like `>>`.

```
cat notes.txt
```
Prints the whole file.

```
head -n 2 notes.txt
```
Shows just the first 2 lines.

```
tail -n 2 notes.txt
```
Shows just the last 2 lines.

## The one-line version

- `>` replace
- `>>` add to the end
- `tee` do it while also showing it on screen
