#!/bin/bash
# =============================================================================
# 10_promoter_tools.sh
# Purpose: Analyze promoter sequences from a two-column text file.
#          Based on Exercise 3 (promoter_seqs.txt).
#
# Usage:
#   bash 10_promoter_tools.sh <promoter_file>
#
# Arguments:
#   $1  = path to promoter sequences file (two columns: ID and sequence)
#
# Input file format (promoter_seqs.txt):
#   sequence.1   ATCGATCG...
#   sequence.2   GCTAGCTA...
#   (tab or space separated: column 1 = ID, column 2 = sequence)
#
# What this script does:
#   Part A: Extract a specific sequence by name or line number
#   Part B: Convert the two-column text file to FASTA format
#   Part C: Find sequences with CCCCCC in the first 50 nucleotides
#
# Key commands demonstrated:
#   awk 'NR==N'                print only line number N
#   awk '{print ">" $1 "\n" $2}'  format as FASTA (>header then sequence)
#   substr($2, 1, 50)          extract first 50 characters of field 2
#   index(string, "pattern")   find position of pattern in string (0 = not found)
#
#
# =============================================================================

PROMOTER_FILE="${1}"

if [[ -z "$PROMOTER_FILE" ]] || [[ ! -f "$PROMOTER_FILE" ]]; then
    echo "Error: please provide a valid promoter sequences file."
    echo "Usage: bash 10_promoter_tools.sh <promoter_file>"
    exit 1
fi

echo "========================================"
echo "  Exercise 3: Promoter Sequence Tools"
echo "  File: $PROMOTER_FILE"
echo "========================================"

# ---- PART A: Extract specific sequences ----
echo ""
echo "--- Part A: Extract sequence.12 ---"

# Method 1: using awk NR (line number)
# NR==12 selects only the 12th line
# {print $1; print $2} prints ID then sequence on separate lines
echo "By line number (NR==12):"
awk 'NR==12 {print $1; print $2}' "$PROMOTER_FILE"

# Method 2: using grep with word boundary
# -E enables extended regex
# '^sequence\.12 ' matches "sequence.12" at the start followed by a space
echo ""
echo "By name match:"
grep -E '^sequence\.12 ' "$PROMOTER_FILE" | awk '{print $1; print $2}'

# Show first 3 and last 3 entries
echo ""
echo "First 3 and last 3 entries:"
{ head -n 3 "$PROMOTER_FILE"; tail -n 3 "$PROMOTER_FILE"; } \
    | awk '{print $1; print $2}'

# ---- PART B: Convert to FASTA format ----
echo ""
echo "--- Part B: Convert to FASTA ---"

# awk builds FASTA format: ">" + ID on one line, sequence on the next
# "\n" inserts a newline between the two fields
OUTPUT_FASTA="${PROMOTER_FILE%.txt}.fa"
awk '{print ">" $1 "\n" $2}' "$PROMOTER_FILE" > "$OUTPUT_FASTA"
echo "Converted to FASTA: $OUTPUT_FASTA"
echo "Preview (first 6 lines):"
head -n 6 "$OUTPUT_FASTA"

# Reverse operation: convert FASTA back to two-column text
# /^>/ matches header lines; substr($0,2) removes the ">"
# next skips to the next line (which is the sequence)
echo ""
echo "Reverse conversion (FASTA to text):"
awk '/^>/ { id = substr($0,2); next } { print id, $0 }' "$OUTPUT_FASTA" | head -n 3

# ---- PART C: Find CCCCCC in first 50 nucleotides ----
echo ""
echo "--- Part C: Sequences with CCCCCC in first 50 nt ---"

# substr($2, 1, 50) extracts the first 50 characters of the sequence
# index(seq, "CCCCCC") returns the position of "CCCCCC" in seq
#   (returns 0 if not found)
# If the position is not 0, we print the sequence ID
echo "Sequences containing CCCCCC in first 50 nucleotides:"
awk '{
    seq = substr($2, 1, 50)
    if (index(seq, "CCCCCC") != 0) {
        print $1
    }
}' "$PROMOTER_FILE"

echo ""
echo "=== Exercise 3 complete ==="
