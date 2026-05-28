#!/bin/bash
# =============================================================================
# 12_batch_processor.sh
# Purpose: Demonstrate awk, sort, and uniq patterns for processing tabular
#          data from CSV batch files. Based on Unit 4 exercises.
#
# Usage:
#   bash 12_batch_processor.sh <batch_folder> [tsv_file]
#
# Arguments:
#   $1  = path to batch_files directory (required)
#   $2  = path to a .tsv file like Nematoda.sm.tsv (optional)
#
# What this script does:
#   1. Find the entry with highest Protein_Concentration per batch
#   2. Find top 3 entries with highest Protein_Concentration across all batches
#   3. Count unique species across all batch files
#   4. Calculate average Expression_Level for Homo sapiens
#   5. If a TSV is provided: find species with most genome assemblies
#
# Key commands demonstrated:
#   awk -F','          set comma as field separator
#   sort -t, -k8,8gr   sort by 8th comma-separated field, general numeric, reverse
#   sort | uniq -c     count unique occurrences
#   sort -nr           sort numerically in reverse
#   NR > 1             skip the header row
#   END { }            awk block that runs after all lines are processed
#
#
# =============================================================================

BATCH_DIR="${1}"

if [[ -z "$BATCH_DIR" ]] || [[ ! -d "$BATCH_DIR" ]]; then
    echo "Error: please provide a valid batch_files directory."
    echo "Usage: bash 12_batch_processor.sh <batch_folder> [tsv_file]"
    exit 1
fi

echo "========================================"
echo "  Batch File Processor"
echo "  Folder: $BATCH_DIR"
echo "========================================"

# ---- 1. Highest Protein_Concentration per batch ----
echo ""
echo "--- 1. Highest Protein_Concentration per batch ---"

# For each batch file:
#   tail -n +2 skips the header (starts from line 2)
#   sort -t',' -k8,8gr sorts by column 8, general numeric, reverse
#   head -n 1 takes only the top entry
#   awk prints the relevant fields
for file in "$BATCH_DIR"/batch.*.csv; do
    if [[ -f "$file" ]]; then
        BASENAME=$(basename "$file")
        TOP=$(tail -n +2 "$file" \
            | sort -t',' -k8,8gr \
            | head -n 1 \
            | awk -F',' '{print "  Conc=" $8 "  Seq=" $3}')
        echo "  $BASENAME: $TOP"
    fi
done

# ---- 2. Top 3 across all batches ----
echo ""
echo "--- 2. Top 3 Protein_Concentration across all batches ---"

# cat all batch files, skip headers with tail
# sort globally, take top 3
cat "$BATCH_DIR"/batch.*.csv 2>/dev/null \
    | awk -F',' 'NR > 1' \
    | sort -t',' -k8,8gr \
    | head -n 3 \
    | awk -F',' '{print "  Conc=" $8 "  Species=" $2 "  Seq=" substr($3,1,20) "..."}'

# ---- 3. Unique species count ----
echo ""
echo "--- 3. Unique species across all batch files ---"

# NR > 1 skips headers
# {print $2} extracts the Species column
# sort | uniq gives unique species names
SPECIES_COUNT=$(awk -F',' 'NR > 1 {print $2}' "$BATCH_DIR"/batch.*.csv 2>/dev/null \
    | sort | uniq | wc -l)
echo "  Total unique species: $SPECIES_COUNT"
echo "  Species list:"
awk -F',' 'NR > 1 {print $2}' "$BATCH_DIR"/batch.*.csv 2>/dev/null \
    | sort | uniq | sed 's/^/    /'

# ---- 4. Average Expression_Level for Homo sapiens ----
echo ""
echo "--- 4. Average Expression_Level for Homo sapiens ---"

# /Homo sapiens/ matches lines containing "Homo sapiens"
# {print $7} extracts the Expression_Level column
# The second awk accumulates the sum and at END prints the average
# x=x+$1 accumulates the sum; NR counts lines processed
AVG=$(awk -F',' '/Homo sapiens/ {print $7}' "$BATCH_DIR"/batch.*.csv 2>/dev/null \
    | awk '{x=x+$1} END {if (NR>0) print x/NR; else print "N/A"}')
echo "  Average Expression_Level (Homo sapiens): $AVG"

# ---- 5. Optional TSV analysis ----
TSV_FILE="${2}"
if [[ -n "$TSV_FILE" ]] && [[ -f "$TSV_FILE" ]]; then
    echo ""
    echo "--- 5. TSV Analysis: $TSV_FILE ---"

    # Find the species with the most genome assemblies
    # awk -F'\t' sets tab as separator
    # {print $2} extracts the species column
    # sort | uniq -c counts occurrences
    # sort -nr puts highest count first
    echo "  Top 5 species by genome assembly count:"
    awk -F'\t' 'NR > 1 {print $2}' "$TSV_FILE" \
        | sort \
        | uniq -c \
        | sort -nr \
        | head -n 5 \
        | awk '{print "    " $1 " assemblies: " $2}'

    # Check for repeated accession IDs
    echo ""
    REPEATED=$(awk -F'\t' 'NR > 1 {print $1}' "$TSV_FILE" | sort | uniq -d)
    if [[ -z "$REPEATED" ]]; then
        echo "  No repeated accession IDs found."
    else
        echo "  Repeated accession IDs:"
        echo "$REPEATED" | sed 's/^/    /'
    fi
fi

echo ""
echo "=== Batch processing complete ==="
