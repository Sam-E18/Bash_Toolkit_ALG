#!/bin/bash
# =============================================================================
# 07_countlines.sh
# Purpose: For each file provided as argument, print its name and number of
#          lines, using correct grammar (zero, one, or plural form).
#          Supports multiple files as arguments.
#
# Usage:
#   bash 07_countlines.sh <file1> [file2] [file3] ...
#
# Examples:
#   bash 07_countlines.sh myfile.txt
#   bash 07_countlines.sh *.txt
#   bash 07_countlines.sh tables/Nematoda.sm.tsv proteins/example.fa
#
# How it works:
#   $@ represents all command-line arguments
#   for FILE in "$@" iterates over each argument
#   wc -l < "$FILE" counts lines (the < redirection avoids printing filename)
#   if/elif/else differentiates between zero, one, and multiple lines
# =============================================================================

# Check that at least one argument was provided
if [[ $# -eq 0 ]]; then
    echo "Error: no file(s) provided."
    echo "Usage: bash 07_countlines.sh <file1> [file2] ..."
    exit 1
fi

# $@ contains all positional parameters (arguments)
# Quoting "$@" preserves spaces in filenames
for FILE in "$@"; do

    # Check that the file exists
    if [[ ! -f "$FILE" ]]; then
        echo "Warning: '$FILE' is not a regular file, skipping."
        continue
    fi

    # Count lines using wc -l
    # The < redirection feeds the file as stdin to wc
    # This avoids wc printing the filename alongside the count
    NLINES=$(wc -l < "$FILE")

    # Use if/elif/else to differentiate singular, plural, and zero
    if [[ "$NLINES" -eq 0 ]]; then
        echo "File '$FILE' contains zero lines (it is empty)."
    elif [[ "$NLINES" -eq 1 ]]; then
        echo "File '$FILE' contains 1 line."
    else
        echo "File '$FILE' contains $NLINES lines."
    fi

done
