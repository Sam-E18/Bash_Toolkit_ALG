#!/bin/bash
# =============================================================================
# 08_label_search.sh
# Purpose: Demonstrates various grep, find, and loop patterns for searching
#          and organizing files by content. Based on Exercise 1 (label_files).
#
# Usage:
#   bash 08_label_search.sh <label_files_folder>
#
# Arguments:
#   $1  = path to the label_files directory (required)
#
# What this script does:
#   Part A: Count files containing specific patterns
#   Part B: Copy files whose names match a digit to a subdirectory
#   Part C: Group files by repeated digits and archive them
#
# Key commands demonstrated:
#   grep -l    list filenames with matches (not the matching lines)
#   grep -c    count matching lines
#   grep -h    suppress filename prefix in output
#   grep -o    print only the matching part
#   wc -l      count lines
#   for/done   loop over a list of items
#   mkdir -p   create directory (and parents if needed, no error if exists)
#   tar czf    create a compressed tar archive
# =============================================================================

LABEL_DIR="${1:-label_files}"

if [[ ! -d "$LABEL_DIR" ]]; then
    echo "Error: directory '$LABEL_DIR' not found."
    echo "Usage: bash 08_label_search.sh <label_files_folder>"
    exit 1
fi

echo "========================================"
echo "  Exercise 1: Label File Analysis"
echo "  Folder: $LABEL_DIR"
echo "========================================"

# ---- PART A: Counting files by content ----
echo ""
echo "--- Part A: Content searches ---"

# Count files containing "1ab" in their content
# grep -l lists only filenames that contain a match
# wc -l counts how many filenames were listed
COUNT_1AB=$(grep -l "1ab" "$LABEL_DIR"/* 2>/dev/null | wc -l)
echo "Files containing '1ab': $COUNT_1AB"

# Count files with header "This is file number 1"
# ^ matches the beginning of a line
COUNT_HEADER1=$(grep -l "^This is file number 1$" "$LABEL_DIR"/* 2>/dev/null | wc -l)
echo "Files with header 'This is file number 1': $COUNT_HEADER1"

# Count files containing a label starting with "c3"
COUNT_C3=$(grep -l "label = c3" "$LABEL_DIR"/* 2>/dev/null | wc -l)
echo "Files with label starting 'c3': $COUNT_C3"

# Count files whose header number is odd (single or double digit)
# -E enables extended regex
# [0-9]* matches zero or more digits
# [13579] matches a single odd digit at the end
COUNT_ODD=$(grep -El '^This is file number [0-9]*[13579]$' "$LABEL_DIR"/* 2>/dev/null | wc -l)
echo "Files with odd-numbered header: $COUNT_ODD"

# ---- PART B: Copy files by name pattern ----
echo ""
echo "--- Part B: Copy files with '4' in name ---"

# Create destination directory
mkdir -p "$LABEL_DIR/selected_files"

# Loop over files whose name contains the digit 4
# The glob *4* matches any filename containing "4"
COUNT_COPIED=0
for f in "$LABEL_DIR"/*4*; do
    # Check that the glob actually matched something (avoid literal *4*)
    if [[ -f "$f" ]]; then
        cp "$f" "$LABEL_DIR/selected_files/"
        COUNT_COPIED=$((COUNT_COPIED + 1))
    fi
done
echo "Copied $COUNT_COPIED files to $LABEL_DIR/selected_files/"

# ---- PART C: Group by repeated digits ----
echo ""
echo "--- Part C: Group files with triple-digit patterns ---"

# For each digit 0-9, find files containing three consecutive copies
# {0..9} is a brace expansion generating 0 1 2 3 4 5 6 7 8 9
# grep -q means "quiet" (no output, just set exit code)
# grep -E enables extended regex for {3} repetition

LFILES=$(find "$LABEL_DIR" -maxdepth 1 -type f)

for digit in {0..9}; do
    DIR="new_dir_$digit"
    mkdir -p "$DIR"
    COUNT=0
    for f in $LFILES; do
        # ${digit}{3} matches the digit repeated 3 times (e.g., 000, 111)
        if grep -q -E "${digit}{3}" "$f" 2>/dev/null; then
            cp "$f" "$DIR/"
            COUNT=$((COUNT + 1))
        fi
    done
    echo "  new_dir_$digit: $COUNT files"

    # Create a tar.gz archive for each subdirectory
    # -c create, -z compress with gzip, -f output filename
    if [[ "$COUNT" -gt 0 ]]; then
        tar czf "${DIR}.tar.gz" "$DIR" 2>/dev/null
    fi
done

echo ""
echo "=== Exercise 1 complete ==="
