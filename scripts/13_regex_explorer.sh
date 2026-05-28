#!/bin/bash
# =============================================================================
# 13_regex_explorer.sh
# Purpose: Demonstrate regular expression patterns at three levels:
#          BRE (Basic), ERE (Extended), and PCRE (Perl-Compatible).
#          Creates a sample text file, then runs grep/egrep/awk examples.
#
# Usage:
#   bash 13_regex_explorer.sh [text_file]
#
# Arguments:
#   $1  = text file to search (optional; if omitted, a sample is generated)
#
# What this script does:
#   1. BRE demos: character classes, anchors, dot wildcard, word boundaries
#   2. ERE demos: alternation (|), quantifiers (+, ?, {n,m}), grouping
#   3. PCRE demos: greedy vs reluctant matching
#   4. Awk pattern demos: field-specific matching, gsub with regex
#   5. Bioinformatics regex: FASTA header parsing, motif searching
#
# Key concepts:
#   .         matches any single character
#   [abc]     matches a, b, or c
#   [a-z]     matches any lowercase letter
#   [^abc]    matches any character EXCEPT a, b, or c
#   ^         anchors to start of line
#   $         anchors to end of line
#   *         zero or more of the previous character
#   +         one or more (ERE only)
#   ?         zero or one (ERE only)
#   {n}       exactly n repetitions (ERE only)
#   {n,m}     between n and m repetitions (ERE only)
#   (a|b)     alternation: matches a or b (ERE only)
#   \d        digit (PCRE only, equivalent to [0-9])
#   .*?       reluctant/non-greedy match (PCRE only)
#
# 
# =============================================================================

# ---- Setup: create or use a sample text file ----
if [[ -n "$1" ]] && [[ -f "$1" ]]; then
    TEXTFILE="$1"
    echo "Using provided file: $TEXTFILE"
else
    # Create a sample file similar to regexp_standards.txt from the course
    TEXTFILE=$(mktemp)
    CREATED_TEMP=1
    cat > "$TEXTFILE" << 'SAMPLE'
The BRE standard was the first regex syntax in Unix tools.
Regular expressions, also known as regex or regexp, are patterns.
The ERE standard extended BRE with new operators like + and ?.
This text contains examples for testing pattern matching skills.
Matching three letter words is a common exercise in this course.
Bioinformatics relies on text processing for sequence analysis.
FASTA files start with a header line beginning with the > symbol.
DNA sequences use nucleotides A T G C while proteins use 20 amino acids.
The year 2024 brought many advances in genomics research at UPF.
Python version 3.11 is commonly used alongside bash scripting.
Gene expression levels were 60.82 and 45.17 for sample groups.
SAMPLE
    echo "Created sample text file for demonstration."
fi

echo ""
echo "========================================"
echo "  Regular Expression Explorer"
echo "========================================"
echo ""
echo "File contents:"
cat "$TEXTFILE"

# ===========================================================
# SECTION 1: BRE (Basic Regular Expressions)
# Used by: grep (default mode), sed
# ===========================================================
echo ""
echo "========================================"
echo "  SECTION 1: BRE (Basic Regular Expressions)"
echo "========================================"

# 1a. The dot (.) matches any single character
# 't..' matches t followed by any two characters
echo ""
echo "1a. Dot wildcard: grep 't..' (t + any 2 chars)"
grep -o 't..' "$TEXTFILE" | sort -u | head -n 10

# 1b. Character classes [abc] match one of the listed chars
# [BE]RE matches either BRE or ERE
echo ""
echo "1b. Character class: grep '[BE]RE' (BRE or ERE)"
grep '[BE]RE' "$TEXTFILE"

# 1c. Ranges inside character classes
# [a-z] matches any lowercase letter
# [A-Z] matches any uppercase letter
# [0-9] matches any digit
echo ""
echo "1c. Three-letter uppercase words: grep -w '[A-Z][A-Z][A-Z]'"
grep -ow '[A-Z][A-Z][A-Z]' "$TEXTFILE" | sort -u

# 1d. Anchors: ^ matches start of line, $ matches end of line
# '^[tT]' matches lines starting with t or T
echo ""
echo "1d. Lines starting with T or t: grep '^[tT]'"
grep '^[tT]' "$TEXTFILE"

# 1e. Word boundary with -w (match whole words only)
# Without -w, 'the' also matches inside 'these', 'other', etc.
echo ""
echo "1e. Whole word 'the': grep -w 'the'"
grep -w 'the' "$TEXTFILE"

# 1f. First word of each line using ^ anchor
# '^[a-zA-Z]*' matches word characters from start of line
echo ""
echo "1f. First word of each line: grep -o '^[a-zA-Z]*'"
grep -o '^[a-zA-Z]*' "$TEXTFILE"

# 1g. Negated character class [^abc] matches anything EXCEPT listed chars
# Words without the letter 'e': [a-df-zA-DF-Z]* (skips e and E)
echo ""
echo "1g. Words without letter 'e': grep -ow '[a-df-zA-DF-Z]*'"
grep -ow '[a-df-zA-DF-Z][a-df-zA-DF-Z]*' "$TEXTFILE" | sort -u | head -n 10

# ===========================================================
# SECTION 2: ERE (Extended Regular Expressions)
# Used by: grep -E (or egrep), awk
# ===========================================================
echo ""
echo "========================================"
echo "  SECTION 2: ERE (Extended Regular Expressions)"
echo "========================================"

# 2a. Alternation with | (OR operator)
# 'regex|regexp' matches either word
echo ""
echo "2a. Alternation: grep -E 'regex|regexp'"
grep -Eo 'regex|regexp' "$TEXTFILE" | sort -u

# 2b. Grouping with () and optional with ?
# 'reg(ular|ex(es)?)' matches: regular, regex, regexes
echo ""
echo "2b. Grouping: grep -E 'reg(ular|ex(es)?)'"
grep -Eo 'reg(ular|ex(es)?)' "$TEXTFILE" | sort -u

# 2c. One or more with + (at least one match required)
# [A-Z]+ matches one or more consecutive uppercase letters
echo ""
echo "2c. One or more uppercase: grep -Eo '[A-Z]+'"
grep -Eo '[A-Z]+' "$TEXTFILE" | sort -u

# 2d. Exact repetitions with {n} and ranges with {n,m}
# [A-Z]{3} matches exactly 3 uppercase letters
echo ""
echo "2d. Exactly 3 uppercase: grep -Eo '[A-Z]{3}'"
grep -Eo '[A-Z]{3}' "$TEXTFILE" | sort -u

# 2e. Capitalized words of 2 to 4 letters
# [A-Z] followed by 1-3 lowercase: one uppercase then 1 to 3 lowercase
echo ""
echo "2e. Capitalized words 2-4 letters: grep -Ew '[A-Z][a-z]{1,3}'"
grep -Eow '[A-Z][a-z]{1,3}' "$TEXTFILE" | sort -u

# 2f. Match numbers (integers and decimals)
# [0-9]+ matches one or more digits
# ([0-9]+\.)?[0-9]+ matches optional decimal part
echo ""
echo "2f. Numbers: grep -Eo '[0-9]+(\.[0-9]+)?'"
grep -Eo '[0-9]+(\.[0-9]+)?' "$TEXTFILE" | sort -u

# ===========================================================
# SECTION 3: PCRE (Perl-Compatible Regular Expressions)
# Used by: grep -P
# ===========================================================
echo ""
echo "========================================"
echo "  SECTION 3: PCRE (Perl-Compatible)"
echo "========================================"

# 3a. Greedy vs reluctant (non-greedy) matching
# Greedy: .* matches as MUCH as possible
# Reluctant: .*? matches as LITTLE as possible (PCRE only)
echo ""
echo "3a. Greedy match (from start to LAST 'the'):"
echo "    grep -Po '^.*the'"
grep -Po '^.*the' "$TEXTFILE" 2>/dev/null | head -n 3

echo ""
echo "3b. Reluctant match (from start to FIRST 'the'):"
echo "    grep -Po '^.*?the'"
grep -Po '^.*?the' "$TEXTFILE" 2>/dev/null | head -n 3

# 3c. \d is a digit shorthand (PCRE equivalent of [0-9])
echo ""
echo "3c. Digits with \\d: grep -Po '\\d+'"
grep -Po '\d+' "$TEXTFILE" 2>/dev/null | sort -u

# ===========================================================
# SECTION 4: Awk Patterns
# Used by: awk (uses ERE syntax by default)
# ===========================================================
echo ""
echo "========================================"
echo "  SECTION 4: Awk Pattern Matching"
echo "========================================"

# 4a. Match lines containing a pattern
# /pattern/ in awk acts as a condition: only matching lines execute the action
echo ""
echo "4a. Lines with 'seq': awk '/seq/' file"
awk '/seq/' "$TEXTFILE"

# 4b. Field-specific matching with ~ operator
# $3 ~ /pattern/ means: third field matches the pattern
echo ""
echo "4b. Lines where field 1 starts with uppercase: awk '\$1 ~ /^[A-Z]/'"
awk '$1 ~ /^[A-Z]/' "$TEXTFILE"

# 4c. gsub with regex: replace all digits with X
echo ""
echo "4c. Replace digits with X: awk '{gsub(/[0-9]/, \"X\"); print}'"
awk '{gsub(/[0-9]/, "X"); print}' "$TEXTFILE" | head -n 3

# 4d. match() function: find position and length of a match
# RSTART = start position, RLENGTH = length of match
echo ""
echo "4d. Find position of numbers: awk with match()"
awk 'match($0, /[0-9]+/) {
    print "  Line " NR ": found \"" substr($0, RSTART, RLENGTH) "\" at position " RSTART
}' "$TEXTFILE"

# 4e. split() with regex delimiter
echo ""
echo "4e. Split on non-word chars: awk split()"
echo "The BRE standard was the first" | awk '{
    n = split($0, words, /[^a-zA-Z]+/)
    for (i=1; i<=n; i++) {
        if (length(words[i]) > 0) print "  word " i ": " words[i]
    }
}'

# ===========================================================
# SECTION 5: Bioinformatics Regex Examples
# ===========================================================
echo ""
echo "========================================"
echo "  SECTION 5: Bioinformatics Regex"
echo "========================================"

# 5a. Match FASTA IDs starting with GAPD followed by 8 digits
echo ""
echo "5a. UniProt-style IDs (GAPD + 8 digits):"
echo "    awk '/^GAPD[0-9]{8}/'"
echo "GAPD12345678,some_data" | awk -F',' '$1 ~ /^GAPD[0-9]{8}/ {print "  Match: " $1}'
echo "GAPD1234,short" | awk -F',' '$1 ~ /^GAPD[0-9]{8}/ {print "  Match: " $1}'
echo "  (only the 8-digit one matches)"

# 5b. Match date patterns (genome assembly dates)
echo ""
echo "5b. Date pattern YYYY-MM-DD:"
echo "    grep -E '[0-9]{4}-[0-1][0-9]-[0-3][0-9]'"
echo "GCA_000001 2022-03-15 assembly" | grep -Eo '[0-9]{4}-[0-1][0-9]-[0-3][0-9]'
echo "GCA_000002 2024-11-30 assembly" | grep -Eo '[0-9]{4}-[0-1][0-9]-[0-3][0-9]'

# 5c. Match DNA motifs (e.g., start codon ATG + 3 more nucleotides)
echo ""
echo "5c. Start codon context (ATG + 3nt):"
echo "GCGATGCCTAAA" | grep -Eo 'ATG[ATGC]{3}'

# 5d. Find lines containing the string '3' not followed by another digit
echo ""
echo "5d. Digit 3 not followed by another digit:"
echo "    awk '/3[^0-9]/ || /3\$/' file"
printf "score=3.5\nscore=35\nscore=3\n" | awk '/3[^0-9]/ || /3$/ {print "  " $0}'

# ---- Cleanup ----
if [[ "$CREATED_TEMP" -eq 1 ]]; then
    rm -f "$TEXTFILE"
fi

echo ""
echo "=== Regex Explorer complete ==="
