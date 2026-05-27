#!/bin/bash
# =============================================================================
# 09_fasta_id_extractor.sh
# Purpose: Extract identifiers, SwissProt entries, and organism names from
#          UniProt-formatted FASTA headers. Based on Exercise 2.
#
# Usage:
#   bash 09_fasta_id_extractor.sh <fasta_file>
#
# Arguments:
#   $1  = path to a UniProt FASTA file (required)
#
# UniProt FASTA header format:
#   >db|UniqueIdentifier|EntryName ProteinName OS=Organism OX=TaxID ...
#   Example:
#   >sp|Q9Y5Y2|CYSZ_HUMAN Cysteine ... OS=Homo sapiens OX=9606 ...
#
# What this script does:
#   Part A: Extract the last identifier (first field of header, without >)
#   Part B: Extract only SwissProt (sp) entries and their entry names
#   Part C: Extract organism names (OS= field) and find the most common
#
# Key commands demonstrated:
#   grep '^>'             select header lines only
#   sed 's/^>//'          remove the leading > character
#   awk '{print $1}'      print the first whitespace-delimited field
#   awk -F'|'             use pipe as field separator
#   awk -F'OS=| OX='      use multiple delimiters to extract OS field
#   sort | uniq -c        count unique occurrences
#   sort -nr              sort numerically in reverse (highest first)
#   tail -n 1             get only the last line
#
# =============================================================================

FASTA="${1}"

if [[ -z "$FASTA" ]] || [[ ! -f "$FASTA" ]]; then
    echo "Error: please provide a valid FASTA file."
    echo "Usage: bash 09_fasta_id_extractor.sh <fasta_file>"
    exit 1
fi

echo "========================================"
echo "  Exercise 2: FASTA ID Extraction"
echo "  File: $FASTA"
echo "========================================"

# ---- PART A: Get the last identifier ----
echo ""
echo "--- Part A: Sequence count and last ID ---"

# Count total sequences
NSEQ=$(grep -c '^>' "$FASTA")
echo "Total sequences: $NSEQ"

# Get the last identifier
# grep '^>'   selects header lines
# sed 's/^>//' removes the ">"
# awk '{print $1}' takes only the first field (the full ID like sp|Q9Y5Y2|CYSZ_HUMAN)
# tail -n 1    takes only the last line
LAST_ID=$(grep '^>' "$FASTA" | sed 's/^>//' | awk '{print $1}' | tail -n 1)
echo "Last identifier: $LAST_ID"

# ---- PART B: Extract SwissProt entries ----
echo ""
echo "--- Part B: SwissProt (sp) entry names ---"

# Step 1: Extract all IDs to a temporary file
TMPIDS=$(mktemp)
grep '^>' "$FASTA" | sed 's/^>//' | awk '{print $1}' > "$TMPIDS"

# Step 2: Filter for sp entries and extract the entry_name (third field)
# awk -F'|' sets the field separator to the pipe character
# $1=="sp" checks if the database is SwissProt
# {print $3} prints the entry name (e.g., CYSZ_HUMAN)
SP_COUNT=$(awk -F'|' '$1=="sp" {print $3}' "$TMPIDS" | wc -l)
echo "SwissProt entries found: $SP_COUNT"
echo "First 5 entry names:"
awk -F'|' '$1=="sp" {print $3}' "$TMPIDS" | head -n 5

# ---- PART C: Extract organism names ----
echo ""
echo "--- Part C: Organism names (OS= field) ---"

# Extract the OS= field from headers
# awk -F'OS=| OX=' uses "OS=" and " OX=" as delimiters
# $2 is the text between those two delimiters = the organism name
# sub() removes trailing parenthetical annotations and numbers
echo "Top 5 most frequent organisms:"
grep '^>' "$FASTA" \
    | sed 's/^>//' \
    | awk -F'OS=| OX=' '{ os = $2; sub(/ \(.*/, "", os); sub(/ [0-9_]+$/, "", os); print os }' \
    | sort \
    | uniq -c \
    | sort -nr \
    | head -n 5

# Clean up
rm -f "$TMPIDS"

echo ""
echo "=== Exercise 2 complete ==="
