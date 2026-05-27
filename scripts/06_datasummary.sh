#!/bin/bash
# =============================================================================
# 06_datasummary.sh
# Purpose: Print a summary of how many files of each type (.fa, .fasta, .tsv,
#          .txt, .csv) exist in a directory and its subfolders.
#
# Usage:
#   bash 06_datasummary.sh [folder]
#
# Arguments:
#   $1  = folder to search (optional, default: current directory ".")
#
# How it works:
#   For each extension, we use find to locate matching files, then wc -l
#   to count how many were found.
#   $(command) captures the output of a command into a variable.
#   $(( expression )) performs arithmetic in bash.
# =============================================================================

FOLDER="${1:-.}"

if [[ ! -d "$FOLDER" ]]; then
    echo "Error: '$FOLDER' is not a valid directory."
    exit 1
fi

echo "=== Data Summary for: $FOLDER ==="
echo ""

# Count files for each extension
# find -type f -name "pattern" | wc -l  counts matching files
N_FA=$(find "$FOLDER" -type f -name "*.fa" | wc -l)
N_FASTA=$(find "$FOLDER" -type f -name "*.fasta" | wc -l)
N_TSV=$(find "$FOLDER" -type f -name "*.tsv" | wc -l)
N_TXT=$(find "$FOLDER" -type f -name "*.txt" | wc -l)
N_CSV=$(find "$FOLDER" -type f -name "*.csv" | wc -l)

# Print results
echo "  .fa files:    $N_FA"
echo "  .fasta files: $N_FASTA"
echo "  .tsv files:   $N_TSV"
echo "  .txt files:   $N_TXT"
echo "  .csv files:   $N_CSV"

# Calculate and print total using arithmetic expansion
TOTAL=$(( N_FA + N_FASTA + N_TSV + N_TXT + N_CSV ))
echo ""
echo "  Total:        $TOTAL"
echo ""
echo "=== End of summary ==="
