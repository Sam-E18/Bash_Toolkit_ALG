#!/bin/bash
# =============================================================================
# 05_discover.sh
# Purpose: Find all hidden files in the current directory and subfolders,
#          then display their long-format information (permissions, size, etc).
#
# Usage:
#   bash 05_discover.sh [folder]
#
# Arguments:
#   $1  = folder to search (optional, default: current directory ".")
#
# How it works:
#   find -type f -name ".*"  finds regular files whose name starts with a dot
#   -exec ls -lh {} \;       runs ls -lh on each found file
#     {}  is replaced by the filename found
#     \;  terminates the -exec command
#
# Note on hidden files:
#   In Linux/Unix, any file whose name starts with a dot (.) is hidden
#   by default. These are usually configuration files like .bashrc,
#   .gitignore, .profile, etc.
#
# =============================================================================

FOLDER="${1:-.}"

if [[ ! -d "$FOLDER" ]]; then
    echo "Error: '$FOLDER' is not a valid directory."
    exit 1
fi

# Count hidden files first
COUNT=$(find "$FOLDER" -type f -name ".*" | wc -l)

if [[ "$COUNT" -gt 0 ]]; then
    echo "Found $COUNT hidden file(s) in $FOLDER:"
    echo ""
    # -exec runs a command for each file found
    # ls -lh gives long format with human-readable sizes
    find "$FOLDER" -type f -name ".*" -exec ls -lh {} \;
else
    echo "No hidden files found in $FOLDER."
fi
