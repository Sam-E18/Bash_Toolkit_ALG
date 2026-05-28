# Awk and Sed Guide (ALG Course Reference)

Comprehensive reference for awk and sed patterns used throughout the ALG course.

## Sed: Stream Editor

Sed processes text line by line, applying transformations without opening a file editor.

### Basic Substitution

```bash
# Replace first occurrence of OLD with NEW on each line
sed 's/OLD/NEW/' file

# Replace ALL occurrences (g = global)
sed 's/OLD/NEW/g' file

# Remove a character (replace with nothing)
sed 's/>//g' file.fa

# Multiple substitutions in one sed call (separated by ;)
sed 's/M/:/g; s/T/./g; s/V/-/g' file
```

### Filtered Substitution

```bash
# Replace only in lines matching a pattern
sed '/pattern/ s/OLD/NEW/g' file

# Replace only in lines NOT matching a pattern (! inverts the filter)
sed '/>/! s/OLD/NEW/g' file

# FASTA example: remove gaps (-) only from sequence lines, not headers
sed '/>/! s/-//g' aligned.fa

# Print only line number 3
sed -n '3p' file
```

### Separator Characters

```bash
# The / separator can be changed to any character
sed 's%M%:%g' file       # using %
sed 's#M#:#g' file       # using #

# Useful when the pattern itself contains /
sed 's|/home/user|/data|g' file
```

### Save Changes In-Place

```bash
# sed -i modifies the file directly (use with caution!)
sed -i 's/old/new/g' file
```

## Tr: Text Translation

Tr translates characters one-to-one. Simpler than sed for character-level replacements.

```bash
# Convert lowercase to uppercase
cat file | tr '[a-z]' '[A-Z]'

# Delete specific characters
echo "ATCG--ATCG" | tr -d '-'
# Output: ATCGATCG

# Squeeze repeated characters into one
echo "AAATTCCC" | tr -s 'A'
# Output: ATTCCC
```

## Awk: Pattern-Action Text Processor

Awk splits each line into fields ($1, $2, ...) and executes actions on matching lines.

### Field Extraction

```bash
# Print first column (default separator: whitespace)
awk '{print $1}' file

# Print specific columns with tab separator
awk -F'\t' '{print $1, $3}' file.tsv

# Print with comma separator
awk -F',' '{print $2}' file.csv

# Use pipe as separator (common in UniProt headers)
awk -F'|' '{print $2}' file

# Print last field
awk '{print $NF}' file

# Print entire line
awk '{print $0}' file
```

### Special Variables

| Variable | Meaning |
|----------|---------|
| `$0` | The entire current line |
| `$1, $2, ...` | First, second, ... field |
| `$NF` | Last field on the line |
| `NR` | Current line number (across all files) |
| `NF` | Number of fields on the current line |
| `FS` | Input field separator (set with -F) |
| `OFS` | Output field separator |
| `FILENAME` | Name of current input file |
| `FNR` | Line number within the current file |

### Conditions (Pattern Matching)

```bash
# Skip the header line (NR > 1 means line number > 1)
awk -F'\t' 'NR > 1 {print $3}' file.tsv

# Match lines containing a pattern
awk '/ORF/ {print $1}' file

# Match a specific field
awk -F'\t' '$5 == "live" {print $1, $8}' file.tsv

# Field matches a pattern (~ operator)
awk -F'\t' '$6 ~ /ORF/ {print $1}' file.tsv

# Combine conditions with && (AND) and || (OR)
awk -F'\t' '($5 == "live") && (NR > 1) {print $1}' file.tsv

# Negate a condition with !
awk -F'\t' '!($5 == "live") {print $1}' file.tsv

# Print only the first 10 lines
awk 'NR <= 10 {print $1}' file

# Numeric comparison
awk -F'\t' '$14 < 22000' file.tsv
```

### Useful Functions

```bash
# length() returns the number of characters in a string
awk '{print "len: " length($0)}' file

# substr(string, start, length) extracts a substring
awk '{print substr($1, 1, 10)}' file          # first 10 chars of field 1
awk '{print substr($0, length($0)-9, 10)}' file  # last 10 chars of line

# index(string, target) finds position of target in string
# Returns 0 if not found
awk '{x = index($0, "atg"); if (x > 0) print x}' file

# split(string, array, separator) breaks a string into parts
awk '/>/ {split($1, A, /:/); print A[2]}' file.fa

# gsub(pattern, replacement, target) replaces ALL matches
# Returns the number of replacements made
awk '!/>/  {gsub(/-/, "", $0); print}' aligned.fa  # remove gaps from sequences

# sub() replaces only the FIRST match
awk '{sub(/^chr/, "", $1); print}' file  # chr1 becomes 1
```

### Custom Variables with -v

```bash
# Pass a bash variable into awk using -v
SIZE=10
awk -v size=$SIZE '{print substr($1, 1, size)}' file

# Pass a computed value
N=$((2 + 2))
awk -v n=$N '{print substr($1, 1, n)}' file
```

### Control Structures

```bash
# If statement inside awk
awk '{if (length($0) > 5) print $0}' file

# Equivalent pattern form (shorter)
awk 'length($0) > 5 {print $0}' file

# For loop inside awk (iterate over fields)
awk '{for (i=1; i<=NF; i++) print i "= " $i}' file

# Extract codons from a sequence
awk '{for (i=1; i<=3; i++) print substr($0, i, 3)}' file
```

### BEGIN and END Blocks

```bash
# BEGIN runs before any line is processed
# END runs after all lines are processed
awk 'BEGIN {print "Starting..."} {print $1} END {print "Done!"}' file

# Count lines and print at the end
awk 'END {print NR " lines processed"}' file

# Sum a column and print the total
awk -F'\t' 'NR > 1 {sum += $4} END {print "Total: " sum}' file.tsv

# Calculate an average
awk -F',' '/Homo sapiens/ {sum += $7; count++} END {
    if (count > 0) print "Average: " sum/count
    else print "No data found"
}' file.csv
```

### Hash Tables (Associative Arrays)

Awk supports associative arrays (like Python dictionaries / hash tables).

```bash
# Count occurrences of each species
awk -F'\t' '{species[$2]++} END {
    for (s in species) print s, species[s]
}' file.tsv

# Find duplicates (second column appears more than once)
awk '($2 in seen) {print "Duplicate: " $0} {seen[$2] = $0}' file

# Sum intron sizes per chromosome
awk -F',' 'NR > 1 {
    CHR[$1] = CHR[$1] + ($4 - $3)
} END {
    for (c in CHR) print c " " CHR[c]
}' constitutive_introns.csv

# Combine: count unique species (equivalent to sort | uniq -c but O(n))
awk -F'\t' '{count[$2]++} END {
    for (sp in count) print count[sp] "\t" sp
}' file.tsv | sort -rn
```

### Awk Scripts in Files

```bash
# Save awk code to a file
cat > myscript.awk << 'EOF'
BEGIN { FS = ","; OFS = "," }
NR == 1 { print; next }
$2 == "Homo sapiens" && $7 != 0 {
    ratio = $9 / $7
    print $1, $2, $7, $9, ratio
}
EOF

# Run the script with -f
awk -f myscript.awk input.csv > output.csv
```

## Common Pipelines

### Sort unique species and count
```bash
awk -F'\t' '{print $2}' file.tsv | sort | uniq -c | sort -nr
```

### Extract FASTA IDs (remove > and take first word)
```bash
grep '^>' file.fa | sed 's/^>//' | awk '{print $1}'
```

### Extract organism names from UniProt headers
```bash
grep '^>' file.fa | awk -F'OS=| OX=' '{print $2}' | sort | uniq -c | sort -nr
```

### Filter and transform in one pipeline
```bash
# From batch CSVs: get expressed Homo sapiens proteins, sort by expression
awk -F',' '$2 == "Homo sapiens" && $4 == "True" {
    print $7 "\t" $1 "\t" $3
}' batch.*.csv | sort -grk1 | head -n 10
```

### Process all files in a loop
```bash
for file in batch.*.csv; do
    echo "=== $file ==="
    awk -F',' 'NR > 1 {print $2}' "$file" | sort | uniq -c | sort -nr | head -n 3
done
```

## Complexity Notes

| Pattern | Complexity |
|---------|-----------|
| `awk '{print $1}' file` | O(n) where n = lines |
| `sort file` | O(n log n) |
| `sort \| uniq -c` | O(n log n) for sort + O(n) for uniq |
| `awk '{HT[$1]++} END{...}'` | O(n) using hash table |
| `grep pattern file` | O(n * L) where L = line length |
| `for each unique: grep file` | O(n * u) where u = unique items (avoid!) |

The last pattern (loop with grep) is a common performance trap. Always prefer
the awk hash table approach for counting by category, as it processes the file
in a single pass.
