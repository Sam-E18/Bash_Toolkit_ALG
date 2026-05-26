# ALG Bash Toolkit

A curated collection of Bash scripts from the **ALG (Algorithms and Linux Genomics)** course. Each script demonstrates essential command-line skills for bioinformatics, genomics data handling, and algorithmic problem-solving in Unix/Linux environments.

## About

This repository merges and extends the work from two previous repositories ([fastatools](https://github.com/Sam-E18/fastatools) and [peekfile](https://github.com/Sam-E18/peekfile)) into a single, well-organized toolkit. Every script includes inline comments explaining what each command does, making this a reference guide for recalling Bash techniques.

## Repository Structure

```
alg_bash_toolkit/
|
|__ README.md
|__ LICENSE
|__ scripts/
|   |__ 01_peek.sh                 # Preview first/last N lines of any file
|   |__ 02_fastascan.sh            # Full FASTA/FA file scanner and reporter
|   |__ 03_fastatitles.sh          # Extract all titles from FASTA files
|   |__ 04_fastafind.sh            # Find all FASTA files in a directory tree
|   |__ 05_discover.sh             # List hidden files with detailed info
|   |__ 06_datasummary.sh          # Summarize file types in a directory
|   |__ 07_countlines.sh           # Count lines with singular/plural grammar
|   |__ 08_label_search.sh         # Search patterns in label files (Exercise 1)
|   |__ 09_fasta_id_extractor.sh   # Extract IDs and organisms from FASTA headers (Exercise 2)
|   |__ 10_promoter_tools.sh       # Promoter sequence analysis (Exercise 3)
|   |__ 11_metagenomics_survey.sh  # Metagenomics species survey (Exercise 4)
|   |__ 12_batch_processor.sh      # Process CSV batch files (awk + sort + uniq)
|   |__ 13_regex_explorer.sh       # Regular expression demos and pattern matching
|   |__ 14_compression_tools.sh    # tar, gzip, zgrep workflows
|   |__ 15_process_manager.sh      # Process monitoring and management
|
|__ docs/
    |__ bash_cheatsheet.md         # Quick reference for common commands
    |__ awk_sed_guide.md           # Awk and Sed patterns used in the course
```

## Scripts Overview

### From peekfile (merged)

| Script | Description |
|--------|-------------|
| `01_peek.sh` | Previews the first and last N lines of a file with "..." separator. Defaults to 3 lines. Shows full content if file is short enough. |

### From fastatools (merged)

| Script | Description |
|--------|-------------|
| `02_fastascan.sh` | Scans a folder for .fa/.fasta files, reports sequence counts, total lengths, nucleotide vs amino acid type, and optionally previews content. |
| `03_fastatitles.sh` | Extracts and prints all sequence headers (without ">") from every FASTA file found in the directory tree. |
| `04_fastafind.sh` | Finds all files with .fa or .fasta extension recursively. |

### New scripts (from ALG course exercises)

| Script | Description |
|--------|-------------|
| `05_discover.sh` | Finds and displays long-format info for all hidden files. |
| `06_datasummary.sh` | Counts .fa, .fasta, .tsv, .txt, .csv files in a directory tree. |
| `07_countlines.sh` | Reports line counts for one or multiple files with proper grammar. |
| `08_label_search.sh` | Demonstrates grep, find, and loop patterns from Exercise 1. |
| `09_fasta_id_extractor.sh` | Extracts sequence IDs, SwissProt entries, and organism names from UniProt FASTA headers (Exercise 2). |
| `10_promoter_tools.sh` | Converts promoter text to FASTA, searches for motifs in first N nucleotides (Exercise 3). |
| `11_metagenomics_survey.sh` | Counts unique species per sea/region from metagenomics sample files (Exercise 4). |
| `12_batch_processor.sh` | Filters, sorts, and aggregates CSV batch data using awk, sort, and uniq. |
| `13_regex_explorer.sh` | Showcases BRE, ERE, and PCRE regex patterns on example files. |
| `14_compression_tools.sh` | Demos for tar, gzip, zgrep, and compressed file inspection. |
| `15_process_manager.sh` | Lists processes, counts non-root processes, and demos background/nohup. |

## How to Use

### 1. Clone the repository

```bash
git clone https://github.com/Sam-E18/alg_bash_toolkit.git
cd alg_bash_toolkit
```

### 2. Make scripts executable

```bash
chmod +x scripts/*.sh
```

### 3. Run any script

```bash
# Form 1: using bash directly
bash scripts/01_peek.sh myfile.txt 5

# Form 2: as executable (needs chmod +x)
./scripts/01_peek.sh myfile.txt 5

# Form 3: as a command (add scripts/ to PATH)
export PATH="$(pwd)/scripts:$PATH"
peek.sh myfile.txt 5
```

### 4. Add to your PATH permanently

```bash
echo 'export PATH="$HOME/Bash_Toolkit_ALG/scripts:$PATH"' >> ~/.bashrc
source ~/.bashrc
```


## Requirements

These scripts use standard Unix/Linux tools available on most systems:
`bash`, `find`, `grep`, `awk`, `sed`, `sort`, `uniq`, `wc`, `head`, `tail`, `cat`, `tr`, `tar`, `gzip`

## Course Reference

These scripts are based on the ALG course by Prof. Marco Mariotti at UPF Barcelona.

## License

GNU General Public License v3.0
