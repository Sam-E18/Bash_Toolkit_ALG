#!/bin/bash
# =============================================================================
# 03_fastatitles.sh
# Purpose: Print all sequence headers (titles) from every .fa/.fasta file
#          found in the current directory and subfolders.
#          The leading ">" character is removed from each title.
#
# Usage:
#   bash 03_fastatitles.sh [folder]
#
# Arguments:
#   $1  = folder to search (optional, default: current directory ".")
#
# Examples:
#   bash 03_fastatitles.sh
#   bash 03_fastatitles.sh ~/data/proteins
#
# How it works:
#   1. find locates all .fa and .fasta files recursively
#   2. grep '^>' selects only header lines (lines starting with >)
#   3. The -h flag suppresses filename prefixes in grep output
#   4. sed removes the leading ">" from each line
#
# Origin: fastatools repository (ALG course, Day 7)
# =============================================================================

FOLDER="${1:-.}"

# Validate the folder
if [[ ! -d "$FOLDER" ]]; then
    echo "Error: '$FOLDER' is not a valid directory."
    exit 1
fi

# find all fasta files, then grep for headers
# -h: do not print filename prefix (we only want titles)
# grep '^>' matches lines that begin with the ">" character
# sed 's/^>//' removes the leading ">" from each matched line
grep -h '^>' $(find "$FOLDER" -type f \( -name "*.fa" -o -name "*.fasta" \)) 2>/dev/null \
    | sed 's/^>//'
