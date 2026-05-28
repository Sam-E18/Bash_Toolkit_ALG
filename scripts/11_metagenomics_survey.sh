#!/bin/bash
# =============================================================================
# 11_metagenomics_survey.sh
# Purpose: Survey metagenomics data: count unique species per sea/region,
#          search for specific taxa across samples. Based on Exercise 4.
#
# Usage:
#   bash 11_metagenomics_survey.sh <metagenomics_folder>
#
# Arguments:
#   $1  = path to the metagenomics directory (required)
#
# Expected structure:
#   metagenomics/
#   |__ seas.list            (one sea name per line)
#   |__ accession2species.tsv (accession to species mapping)
#   |__ adriatic_sea/
#   |   |__ epipelagic/
#   |   |__ mesopelagic/
#   |__ north_sea/
#   |   |__ ...
#
# What this script does:
#   Part A: Count .txt files inside each "epipelagic" directory
#   Part B: Count unique species per sea (using seas.list)
#   Part C: Find Nannochloropsis accessions in sample files
#
# Key commands demonstrated:
#   find -path '*/pattern/*'  find files matching a path pattern
#   while read SEA; do ... done < file   read lines from a file
#   sort -u / sort | uniq     get unique entries
#   grep -R                    recursive grep across files
#
# =============================================================================

META_DIR="${1}"

if [[ -z "$META_DIR" ]] || [[ ! -d "$META_DIR" ]]; then
    echo "Error: please provide a valid metagenomics directory."
    echo "Usage: bash 11_metagenomics_survey.sh <metagenomics_folder>"
    exit 1
fi

echo "========================================"
echo "  Exercise 4: Metagenomics Survey"
echo "  Folder: $META_DIR"
echo "========================================"

# ---- PART A: Count txt files in epipelagic directories ----
echo ""
echo "--- Part A: Files in epipelagic directories ---"

# find all directories named "epipelagic" under the metagenomics folder
# Then, for each one, count .txt files inside (maxdepth 1 = no subdirectories)
for dir in $(find "$META_DIR" -type d -name "epipelagic"); do
    count=$(find "$dir" -maxdepth 1 -type f -name '*.txt' | wc -l)
    echo "  $dir: $count files"
done

# Alternative using -path to find .txt files inside any epipelagic folder
# -printf '%h\n' prints only the directory portion of each match
TOTAL_EPIPELAGIC=$(find "$META_DIR" -type f -path '*/epipelagic/*.txt' | wc -l)
echo "  Total epipelagic .txt files: $TOTAL_EPIPELAGIC"

# ---- PART B: Unique species per sea ----
echo ""
echo "--- Part B: Unique species per sea ---"

SEAS_LIST="$META_DIR/seas.list"
if [[ -f "$SEAS_LIST" ]]; then
    # Read each sea name from the file
    # while read assigns each line to the variable SEA
    while read SEA; do
        # Find all .txt files for this sea
        FILES=$(find "$META_DIR/$SEA" -type f -name '*.txt' 2>/dev/null)
        if [[ -n "$FILES" ]]; then
            # Extract first field (accession), get unique count
            # awk '{print $1}' takes the first column
            # sort -u gives unique entries
            UNIQUE=$(awk '{print $1}' $FILES | sort -u | wc -l)
            echo "  $SEA: $UNIQUE unique species"
        else
            echo "  $SEA: no sample files found"
        fi
    done < "$SEAS_LIST"
else
    echo "  Warning: seas.list not found in $META_DIR"
fi

# ---- PART C: Search for Nannochloropsis ----
echo ""
echo "--- Part C: Nannochloropsis search ---"

ACC_FILE="$META_DIR/accession2species.tsv"
if [[ -f "$ACC_FILE" ]]; then
    # Extract all accessions associated with Nannochloropsis
    echo "Nannochloropsis accessions:"
    NANNO_IDS=$(grep "Nannochloropsis" "$ACC_FILE" | awk '{print $1}')

    if [[ -z "$NANNO_IDS" ]]; then
        echo "  No Nannochloropsis entries found in accession2species.tsv"
    else
        # For each accession, check which sample .txt files contain it
        echo "$NANNO_IDS" | while read acc; do
            # Search recursively in all .txt files using find + grep
            # find locates .txt files, xargs passes them to grep
            hits=$(find "$META_DIR/" -type f -name '*.txt' -exec grep -l "$acc" {} + 2>/dev/null)
            if [[ -n "$hits" ]]; then
                echo "  $acc found in:"
                echo "$hits" | sed 's/^/    /'
            else
                echo "  $acc: not found in any sample file"
            fi
        done
    fi
else
    echo "  Warning: accession2species.tsv not found in $META_DIR"
fi

echo ""
echo "=== Exercise 4 complete ==="
