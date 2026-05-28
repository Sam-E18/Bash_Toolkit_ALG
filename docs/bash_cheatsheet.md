# Bash Cheatsheet (ALG Course Reference)

Quick reference for the most common commands and patterns used throughout the course.

## Navigation and File Inspection

| Command | What it does |
|---------|-------------|
| `pwd` | Print working (current) directory |
| `ls` | List files in current directory |
| `ls -lhrt` | Long format, human-readable sizes, sorted by time (reverse) |
| `cd folder` | Change directory |
| `cd -` | Go back to previous directory |
| `cd` | Go to home directory |
| `cat file` | Display file contents |
| `less file` | View file with scrolling (press q to quit) |
| `head -n 5 file` | Show first 5 lines |
| `tail -n 5 file` | Show last 5 lines |
| `wc -l file` | Count lines |
| `wc -w file` | Count words |
| `wc -c file` | Count characters (bytes) |

## File Operations

| Command | What it does |
|---------|-------------|
| `cp src dest` | Copy file |
| `mv src dest` | Move or rename file |
| `rm file` | Delete file (irreversible!) |
| `rm -r folder` | Delete folder and contents |
| `mkdir -p path` | Create directory (and parents if needed) |
| `ln -s target link` | Create symbolic link |
| `chmod a+x file` | Make file executable for all users |
| `find . -type f -name "*.fa"` | Find files by name pattern |
| `find . -type d` | Find directories |

## Grep (Search Inside Files)

| Command | What it does |
|---------|-------------|
| `grep "pattern" file` | Find lines matching pattern |
| `grep -c "pattern" file` | Count matching lines |
| `grep -l "pattern" files` | List filenames with matches |
| `grep -i "pattern" file` | Case-insensitive search |
| `grep -v "pattern" file` | Invert: show non-matching lines |
| `grep -w "word" file` | Match whole words only |
| `grep -r "pattern" dir/` | Search recursively in directory |
| `grep -o "pattern" file` | Print only the matching part |
| `grep -E "pat1\|pat2" file` | Extended regex: match pat1 OR pat2 |
| `grep '^>' file.fa` | Match FASTA headers (lines starting with >) |

## Awk (Text Processing)

| Command | What it does |
|---------|-------------|
| `awk '{print $1}' file` | Print first column |
| `awk -F'\t' '{print $3}' file` | Print 3rd column (tab-separated) |
| `awk -F',' 'NR>1 {print $2}' f` | Print 2nd column, skip header |
| `awk '/pattern/ {print}' file` | Print lines matching pattern |
| `awk '{print NR, $0}' file` | Print line numbers + content |
| `awk '{print length($0)}' file` | Print length of each line |
| `awk '{print substr($1,1,10)}' f` | Print first 10 chars of field 1 |
| `awk -F'\|' '{print $2}' file` | Use pipe as separator |
| `awk 'END {print NR}' file` | Print total line count at end |

## Sed (Stream Editor)

| Command | What it does |
|---------|-------------|
| `sed 's/old/new/' file` | Replace first occurrence per line |
| `sed 's/old/new/g' file` | Replace all occurrences |
| `sed 's/^>//' file` | Remove ">" from line starts |
| `sed '/>/! s/-//g' file` | Remove dashes only in non-header lines |
| `sed -n '3p' file` | Print only line 3 |

## Sort and Uniq

| Command | What it does |
|---------|-------------|
| `sort file` | Sort alphabetically |
| `sort -n file` | Sort numerically |
| `sort -nr file` | Sort numerically, reverse |
| `sort -k2 file` | Sort by 2nd column |
| `sort -t',' -nk3 file` | Sort by 3rd comma-separated column |
| `sort \| uniq` | Remove duplicate lines (must be sorted first) |
| `sort \| uniq -c` | Count occurrences of each unique line |
| `sort \| uniq -d` | Show only duplicated lines |

## Variables and Arithmetic

```bash
# Variable assignment (no spaces around =)
myvar="hello"
echo $myvar

# Command substitution: capture output in a variable
FILES=$(find . -name "*.fa")
COUNT=$(wc -l < myfile.txt)

# Arithmetic expansion
TOTAL=$(( 5 + 3 ))
DOUBLE=$(( COUNT * 2 ))
```

## Flow Control

```bash
# If statement
if [[ -e "$FILE" ]]; then
    echo "file exists"
elif [[ -d "$FILE" ]]; then
    echo "it is a directory"
else
    echo "not found"
fi

# For loop (word list)
for item in a b c; do echo $item; done

# For loop (files)
for f in *.fa; do echo $f; done

# For loop (command output)
for f in $(find . -name "*.fa"); do echo $f; done

# For loop (C-style)
for ((i=1; i<=10; i++)); do echo $i; done

# While read (line by line from file)
cat myfile.txt | while read line; do echo $line; done

# While read (from find)
find . -name "*.txt" | while read -r f; do echo $f; done
```

## Test Operators

| Test | Meaning |
|------|---------|
| `-e file` | File exists |
| `-f file` | Is a regular file |
| `-d file` | Is a directory |
| `-s file` | File exists and is not empty |
| `-h file` | Is a symbolic link |
| `-r file` | Is readable |
| `-w file` | Is writable |
| `-x file` | Is executable |
| `-z "$var"` | String is empty |
| `-n "$var"` | String is not empty |
| `$a -eq $b` | Numbers are equal |
| `$a -gt $b` | a greater than b |
| `$a -lt $b` | a less than b |
| `$a -ge $b` | a greater or equal |
| `"$a" == "$b"` | Strings are equal |

## Compression

| Command | What it does |
|---------|-------------|
| `gzip file` | Compress file (replaces original) |
| `gunzip file.gz` | Decompress |
| `tar czf archive.tar.gz folder/` | Create compressed archive |
| `tar xzf archive.tar.gz` | Extract compressed archive |
| `zless file.gz` | View compressed file |
| `zgrep "pattern" file.gz` | Search inside compressed file |

## Redirections and Pipes

| Syntax | Meaning |
|--------|---------|
| `cmd > file` | Redirect stdout to file (overwrite) |
| `cmd >> file` | Redirect stdout to file (append) |
| `cmd 2> file` | Redirect stderr to file |
| `cmd &> file` | Redirect both stdout and stderr |
| `cmd1 \| cmd2` | Pipe: output of cmd1 becomes input of cmd2 |
| `cmd1 && cmd2` | Run cmd2 only if cmd1 succeeds |
| `cmd1 \|\| cmd2` | Run cmd2 only if cmd1 fails |
