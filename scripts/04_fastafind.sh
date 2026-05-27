#!/bin/bash
# =============================================================================
# 04_fastafind.sh
# Purpose: Find all files with .fa or .fasta extension in the current
#          directory and subfolders.
#
# Usage:
#   bash 04_fastafind.sh [folder]
#
# Arguments:
#   $1  = folder to search (optional, default: current directory ".")
#
# Examples:
#   bash 04_fastafind.sh
#   bash 04_fastafind.sh ~/data
#
# How it works:
#   find searches recursively starting from the given folder
#   -type f restricts to regular files (not directories)
#   -name matches filename patterns
#   -o means OR (logical operator in find)
#
# Origin: fastatools repository (ALG course, Day 4/5)
# =============================================================================

FOLDER="${1:-.}"

if [[ ! -d "$FOLDER" ]]; then
    echo "Error: '$FOLDER' is not a valid directory."
    exit 1
fi

# find recursively for .fa or .fasta files
# The parentheses \( \) group the -name conditions with -o (OR)
find "$FOLDER" -type f \( -name "*.fa" -o -name "*.fasta" \)
