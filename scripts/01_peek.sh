#!/bin/bash
# =============================================================================
# 01_peek.sh
# Purpose: Preview the first and last N lines of an input file.
#          If the file is short enough (2*N lines or fewer), show full content.
#          Defaults to 3 lines if no second argument is provided.
#
# Usage:
#   bash 01_peek.sh <file> [number_of_lines]
#
# Examples:
#   bash 01_peek.sh myfile.txt          # shows first 3 and last 3 lines
#   bash 01_peek.sh myfile.txt 5        # shows first 5 and last 5 lines
#
# Arguments:
#   $1  = path to the input file (required)
#   $2  = number of lines to display on each end (optional, default: 3)
#
# Origin: peekfile repository (ALG course, Unit 3 homework)
# =============================================================================

# Check that at least one argument was provided
# -z tests if a string is empty (zero length)
if [[ -z "$1" ]]; then
    echo "Error: no file provided."
    echo "Usage: bash 01_peek.sh <file> [number_of_lines]"
    exit 1
fi

# Store the file path in a variable for readability
FILE="$1"

# Check that the file actually exists using the -e test
# -e returns true if the file exists
if [[ ! -e "$FILE" ]]; then
    echo "Error: file '$FILE' does not exist."
    exit 1
fi

# Check that it is a regular file (not a directory) using -f
if [[ ! -f "$FILE" ]]; then
    echo "Error: '$FILE' is not a regular file."
    exit 1
fi

# Set the number of lines: use $2 if provided, otherwise default to 3
# The ${var:-default} syntax means: use $var if set, else use "default"
N=${2:-3}

# Count how many lines the file has
# wc -l counts lines; we pipe through awk to get just the number
TOTAL=$(wc -l < "$FILE")

# Calculate the threshold: if file has 2*N lines or fewer, show everything
THRESHOLD=$(( N * 2 ))

if [[ "$TOTAL" -le "$THRESHOLD" ]]; then
    # File is short enough: display full content
    echo "=== $FILE ($TOTAL lines, showing full content) ==="
    cat "$FILE"
else
    # File is longer: show first N, then "...", then last N
    echo "=== $FILE ($TOTAL lines, showing first and last $N) ==="
    # head -n N prints the first N lines
    head -n "$N" "$FILE"
    echo "..."
    # tail -n N prints the last N lines
    tail -n "$N" "$FILE"
fi
