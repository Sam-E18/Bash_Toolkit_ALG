#!/bin/bash
# =============================================================================
# 14_compression_tools.sh
# Purpose: Demonstrate data compression and inspection workflows using
#          gzip, tar, and z* commands. Based on Unit 4 (Data compression).
#
# Usage:
#   bash 14_compression_tools.sh [folder]
#
# Arguments:
#   $1  = folder to work with (optional, default: current directory ".")
#
# What this script does:
#   1. Gzip: compress and decompress a single file
#   2. Tar: pack multiple files into an archive
#   3. Tar + gzip: compress a whole folder
#   4. Z-commands: inspect compressed files without extracting
#   5. Zgrep: search patterns inside compressed files
#   6. Archive all FASTA files into a single compressed bundle
#
# Key commands:
#   gzip file           compress file (replaces original with file.gz)
#   gunzip file.gz      decompress back to original
#   gunzip -c file.gz   decompress to stdout (original stays compressed)
#   tar -cf a.tar files create a tar archive (no compression)
#   tar -czf a.tar.gz d create a compressed tar archive of directory d
#   tar -xzf a.tar.gz   extract a compressed tar archive
#   tar -tzvf a.tar.gz  list contents of archive without extracting
#   zless file.gz       view compressed file (like less)
#   zgrep "pat" file.gz grep inside compressed file
#   zgrep -l "pat" *.gz list compressed files containing pattern
#
# Origin:  Unit 4 Day 11 (Data compression)
# =============================================================================

FOLDER="${1:-.}"

if [[ ! -d "$FOLDER" ]]; then
    echo "Error: '$FOLDER' is not a valid directory."
    exit 1
fi

echo "========================================"
echo "  Compression Tools Demo"
echo "  Working folder: $FOLDER"
echo "========================================"

# Create a temporary workspace to avoid modifying user files
WORKDIR=$(mktemp -d)
echo "  Temp workspace: $WORKDIR"

# ---- 1. Gzip: single file compression ----
echo ""
echo "=== 1. GZIP: Single File Compression ==="

# Create a sample file
echo "This is a test file for gzip compression demo." > "$WORKDIR/sample.txt"
echo "It contains multiple lines of text." >> "$WORKDIR/sample.txt"
echo "Gzip will compress it significantly." >> "$WORKDIR/sample.txt"

# Show original size
# ls -lh shows human-readable file sizes
ORIG_SIZE=$(ls -lh "$WORKDIR/sample.txt" | awk '{print $5}')
echo "  Original file: sample.txt ($ORIG_SIZE)"

# Compress with gzip
# gzip replaces the file with a .gz version
cp "$WORKDIR/sample.txt" "$WORKDIR/sample_backup.txt"
gzip "$WORKDIR/sample.txt"
GZ_SIZE=$(ls -lh "$WORKDIR/sample.txt.gz" | awk '{print $5}')
echo "  After gzip:    sample.txt.gz ($GZ_SIZE)"
echo "  Note: gzip replaces the original file"

# Decompress with gunzip
gunzip "$WORKDIR/sample.txt.gz"
echo "  After gunzip:  sample.txt restored"

# View without decompressing using gunzip -c
# gunzip -c sends output to stdout, file stays compressed
gzip "$WORKDIR/sample.txt"
echo ""
echo "  View compressed file without extracting (gunzip -c | head):"
gunzip -c "$WORKDIR/sample.txt.gz" | head -n 2 | sed 's/^/    /'

# ---- 2. Tar: packing multiple files ----
echo ""
echo "=== 2. TAR: Pack Multiple Files ==="

# Create some sample files
for i in {1..5}; do
    echo "Content of file $i" > "$WORKDIR/file_$i.txt"
done

# Create a tar archive (no compression)
# -c create archive
# -f specify output filename
tar -cf "$WORKDIR/files.tar" -C "$WORKDIR" file_1.txt file_2.txt file_3.txt file_4.txt file_5.txt
TAR_SIZE=$(ls -lh "$WORKDIR/files.tar" | awk '{print $5}')
echo "  Created files.tar ($TAR_SIZE) from 5 text files"

# List contents of tar without extracting
# -t list contents
# -f specify the archive
echo "  Contents of archive:"
tar -tf "$WORKDIR/files.tar" | sed 's/^/    /'

# Extract to a new folder
mkdir -p "$WORKDIR/extracted"
tar -xf "$WORKDIR/files.tar" -C "$WORKDIR/extracted"
echo "  Extracted to: extracted/"
ls "$WORKDIR/extracted" | sed 's/^/    /'

# ---- 3. Tar + Gzip: compressed archive ----
echo ""
echo "=== 3. TAR.GZ: Compressed Archive ==="

# Create a compressed archive of a folder
# -c create, -z use gzip compression, -f output file
mkdir -p "$WORKDIR/mydata"
for i in {1..3}; do
    echo ">sequence_$i" > "$WORKDIR/mydata/seq_$i.fa"
    echo "ATCGATCGATCG" >> "$WORKDIR/mydata/seq_$i.fa"
done

tar -czf "$WORKDIR/mydata.tar.gz" -C "$WORKDIR" mydata
TARGZ_SIZE=$(ls -lh "$WORKDIR/mydata.tar.gz" | awk '{print $5}')
echo "  Created mydata.tar.gz ($TARGZ_SIZE)"

# List contents with verbose
# -t list, -z decompress, -v verbose (shows sizes), -f file
echo "  Contents (verbose):"
tar -tzvf "$WORKDIR/mydata.tar.gz" | sed 's/^/    /'

# Extract with verbose
mkdir -p "$WORKDIR/unpacked"
tar -xzvf "$WORKDIR/mydata.tar.gz" -C "$WORKDIR/unpacked" 2>&1 | sed 's/^/    /'
echo "  Unpacked successfully"

# ---- 4. Z-commands: inspect without extracting ----
echo ""
echo "=== 4. Z-COMMANDS: Inspect Compressed Files ==="

# Create a compressed sample
echo -e "Line 1: ATCGATCG\nLine 2: GCTAGCTA\nLine 3: TTTTTTT\nLine 4: AAAAAAA" \
    > "$WORKDIR/sequences.txt"
gzip "$WORKDIR/sequences.txt"

# zless: view compressed file (like less but for .gz)
echo "  zcat (print compressed file to stdout):"
zcat "$WORKDIR/sequences.txt.gz" | sed 's/^/    /'

# gunzip -c is equivalent to zcat
echo ""
echo "  gunzip -c (same result as zcat):"
gunzip -c "$WORKDIR/sequences.txt.gz" | head -n 2 | sed 's/^/    /'

# ---- 5. Zgrep: search inside compressed files ----
echo ""
echo "=== 5. ZGREP: Search Inside Compressed Files ==="

# Create multiple compressed files for searching
for i in {1..4}; do
    echo -e "sample_$i\nATCGATCG\nTTTTTTT" > "$WORKDIR/sample_$i.txt"
done
echo -e "sample_5\nGCGCGCGC\nAAAAAAAA" > "$WORKDIR/sample_5.txt"
gzip "$WORKDIR"/sample_*.txt

# zgrep searches inside compressed files
# Just like grep, but handles .gz transparently
echo "  Search for 'TTTTTTT' in compressed files:"
echo "  zgrep -l 'TTTTTTT' *.gz  (list matching files)"
zgrep -l "TTTTTTT" "$WORKDIR"/sample_*.txt.gz 2>/dev/null | while read f; do
    echo "    $(basename $f)"
done

echo ""
echo "  Search for 'GCGC' in compressed files:"
zgrep "GCGC" "$WORKDIR"/sample_*.txt.gz 2>/dev/null | sed 's/^/    /'

# Using a loop to check each compressed file
echo ""
echo "  Loop: for each .gz, check if it contains 'AAAA':"
for f in "$WORKDIR"/sample_*.txt.gz; do
    BASENAME=$(basename "$f")
    if zgrep -q "AAAA" "$f" 2>/dev/null; then
        echo "    $BASENAME: YES"
    else
        echo "    $BASENAME: no"
    fi
done

# ---- 6. Archive all FASTA files ----
echo ""
echo "=== 6. Practical: Archive FASTA Files ==="

# find all .fa/.fasta files and create a compressed archive
# The -T - flag tells tar to read filenames from stdin
FA_COUNT=$(find "$FOLDER" -type f \( -name "*.fa" -o -name "*.fasta" \) 2>/dev/null | wc -l)
echo "  Found $FA_COUNT fasta/fa files in $FOLDER"

if [[ "$FA_COUNT" -gt 0 ]]; then
    # find pipes filenames into tar via -T -
    # -T - means "read file list from standard input"
    find "$FOLDER" -type f \( -name "*.fa" -o -name "*.fasta" \) 2>/dev/null \
        | tar -czf "$WORKDIR/all_fasta.tar.gz" -T -
    ARCHIVE_SIZE=$(ls -lh "$WORKDIR/all_fasta.tar.gz" | awk '{print $5}')
    echo "  Created all_fasta.tar.gz ($ARCHIVE_SIZE)"
    echo "  Archive contents:"
    tar -tzf "$WORKDIR/all_fasta.tar.gz" | head -n 10 | sed 's/^/    /'
else
    echo "  No fasta files found, skipping archive creation"
fi

# ---- Cleanup ----
rm -rf "$WORKDIR"

echo ""
echo "=== Compression Tools demo complete ==="
