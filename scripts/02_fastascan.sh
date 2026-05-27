#!/bin/bash
# =============================================================================
# 02_fastascan.sh
# Purpose: Produce a concise report about FASTA/FA files in a given folder
#          and its subfolders at any depth.
#
# Usage:
#   bash 02_fastascan.sh [folder] [N_lines]
#
# Arguments:
#   $1  = folder to search (optional, default: current directory ".")
#   $2  = number of lines to preview per file (optional, default: 0 = skip)
#
# Examples:
#   bash 02_fastascan.sh                        # scan current dir, no preview
#   bash 02_fastascan.sh ~/data                 # scan ~/data, no preview
#   bash 02_fastascan.sh ~/data 5               # scan ~/data, preview 5 lines
#
# Report includes:
#   - Total number of .fa/.fasta files found
#   - Total unique FASTA IDs across all files
#   - Per file: symlink status, sequence count, total sequence length,
#     nucleotide/amino acid type detection, and optional content preview
# =============================================================================

# Set folder and line count with defaults
# ${1:-.} means: use $1 if provided, otherwise use "."
FOLDER="${1:-.}"
N="${2:-0}"

# Validate that the folder exists using -d (is directory?)
if [[ ! -d "$FOLDER" ]]; then
    echo "Error: '$FOLDER' is not a valid directory."
    exit 1
fi

# ---- Find all FASTA files ----
# find searches recursively for files matching .fa or .fasta extensions
# We store results in a temporary file to iterate multiple times
TMPFILE=$(mktemp)
find "$FOLDER" -type f \( -name "*.fa" -o -name "*.fasta" \) > "$TMPFILE"

# Count how many FASTA files we found
# wc -l counts lines in the temp file (one file path per line)
NFILES=$(wc -l < "$TMPFILE")
echo "========================================"
echo "  FASTA SCAN REPORT"
echo "  Folder: $FOLDER"
echo "========================================"
echo "Total fasta/fa files found: $NFILES"

# ---- Count unique FASTA IDs across all files ----
# grep '^>' selects header lines (start with >)
# awk '{print $1}' extracts the first word (the ID)
# sed 's/^>//' removes the leading ">"
# sort -u gives unique entries; wc -l counts them
if [[ "$NFILES" -gt 0 ]]; then
    UNIQUE_IDS=$(grep -h '^>' $(cat "$TMPFILE") 2>/dev/null \
        | awk '{print $1}' \
        | sed 's/^>//' \
        | sort -u \
        | wc -l)
    echo "Total unique fasta IDs: $UNIQUE_IDS"
fi
echo "========================================"

# ---- Per-file report ----
# while read iterates line by line over the file list
while read -r FILE; do
    echo ""
    echo "  File: $FILE"

    # Check if the file is a symbolic link using -h test
    if [[ -h "$FILE" ]]; then
        echo "  Symlink: YES"
    else
        echo "  Symlink: NO"
    fi

    # Count the number of sequences (lines starting with ">")
    # grep -c counts matching lines
    NSEQ=$(grep -c '^>' "$FILE" 2>/dev/null)
    echo "  Number of sequences: $NSEQ"

    # Calculate total sequence length
    # grep -v '^>' excludes header lines (keeps only sequence lines)
    # tr -d removes gaps (-), spaces, newlines, carriage returns
    # wc -c counts the remaining characters (= total sequence length)
    SEQ_LENGTH=$(grep -v '^>' "$FILE" 2>/dev/null \
        | tr -d ' \t\n\r-' \
        | wc -c)
    echo "  Total sequence length: $SEQ_LENGTH"

    # ---- Detect if nucleotide or amino acid ----
    # Strategy: extract sequence characters, check for amino-acid-only letters
    # Nucleotide sequences contain mostly A, T, G, C, U, N (and lowercase)
    # Amino acid sequences contain letters like D, E, F, H, I, K, L, M, etc.
    # We check if non-nucleotide letters (DEFHIKLMPQRSVWY) appear
    # If they do, it is amino acid; otherwise nucleotide
    if [[ "$NSEQ" -gt 0 ]]; then
        # Get a sample of sequence characters (first 500 non-header chars)
        SAMPLE=$(grep -v '^>' "$FILE" 2>/dev/null \
            | tr -d ' \t\n\r-' \
            | head -c 500)
        # grep -i makes it case insensitive
        # [DEFHIKLMPQRSVWY] are amino acid letters not found in nucleotide seqs
        if echo "$SAMPLE" | grep -qi '[DEFHIKLMPQRSVWY]'; then
            echo "  Type: Amino Acids"
        else
            echo "  Type: Nucleotides"
        fi
    fi

    # ---- Optional content preview ----
    # Only if N > 0 (user requested a preview)
    if [[ "$N" -gt 0 ]]; then
        # Count total lines in the file
        TOTAL_LINES=$(wc -l < "$FILE")
        THRESHOLD=$(( N * 2 ))
        echo "  Content preview:"
        if [[ "$TOTAL_LINES" -le "$THRESHOLD" ]]; then
            # Short file: show all content, indented
            sed 's/^/    /' "$FILE"
        else
            # Long file: show first N and last N lines
            head -n "$N" "$FILE" | sed 's/^/    /'
            echo "    ..."
            tail -n "$N" "$FILE" | sed 's/^/    /'
        fi
    fi

    echo "  ----------------------------------------"

done < "$TMPFILE"

# Clean up the temporary file
rm -f "$TMPFILE"

echo ""
echo "=== End of report ==="
