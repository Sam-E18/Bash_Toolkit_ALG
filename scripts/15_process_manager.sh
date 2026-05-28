#!/bin/bash
# =============================================================================
# 15_process_manager.sh
# Purpose: Demonstrate process monitoring, inspection, and management
#          commands from the Unix command line. Based on Unit 2.
#
# Usage:
#   bash 15_process_manager.sh
#
# What this script does:
#   1. List current processes (ps, ps aux)
#   2. Count processes by user (root vs non-root)
#   3. Find specific processes by name (pgrep)
#   4. Demonstrate background execution (&) and nohup
#   5. Show how to identify and terminate processes
#
# Key commands:
#   ps                  show processes in current terminal
#   ps aux              show ALL processes with full details
#   ps -u root          show processes owned by root
#   ps -e -o user=      show only the user column for all processes
#   pgrep <name>        find PIDs of processes matching name
#   top / htop          interactive process monitor
#   kill <PID>          terminate a process by its PID
#   sleep N &           run a command in the background
#   nohup cmd &         run command immune to terminal close
#   jobs                list background jobs in current shell
#   bg / fg             move jobs to background / foreground
#   Ctrl+Z              suspend current foreground process
#   Ctrl+C              interrupt (terminate) current process
#
# The $? variable:
#   After any command, $? holds its exit code:
#   0 = success, nonzero = error/failure
#
# Origin: Unit 2 (Process managing, Day 6)
# =============================================================================

echo "========================================"
echo "  Process Manager Demo"
echo "========================================"

# ---- 1. Current processes ----
echo ""
echo "=== 1. Current Shell Processes ==="

# ps without options shows processes in the current terminal session
# PID  = Process ID (unique number for each process)
# TTY  = Terminal associated with the process
# TIME = CPU time used
# CMD  = Command that started the process
echo "  Processes in this terminal (ps):"
ps | sed 's/^/    /'

# ---- 2. All system processes ----
echo ""
echo "=== 2. System Process Summary ==="

# ps aux shows ALL processes with details:
# USER = owner, PID = process ID, %CPU, %MEM, VSZ, RSS,
# TTY, STAT (state), START, TIME, COMMAND
TOTAL_PROCS=$(ps aux | wc -l)
# Subtract 1 for the header line
TOTAL_PROCS=$((TOTAL_PROCS - 1))
echo "  Total running processes: $TOTAL_PROCS"

# ---- 3. Count by user ----
echo ""
echo "=== 3. Processes by User ==="

# Count root processes
# ps -u root lists all processes owned by root
# wc -l counts the lines; subtract 1 for header
ROOT_COUNT=$(ps -u root 2>/dev/null | tail -n +2 | wc -l)
echo "  Root processes: $ROOT_COUNT"

# Count non-root processes
# ps -e -o user= prints only the username column for every process
# the trailing = suppresses the header
# grep -v '^root$' excludes lines containing only "root"
NONROOT_COUNT=$(ps -e -o user= | grep -v '^root$' | wc -l)
echo "  Non-root processes: $NONROOT_COUNT"

# Show top 5 users by process count
echo ""
echo "  Top 5 users by process count:"
# ps -e -o user= gets all usernames
# sort | uniq -c counts occurrences of each username
# sort -rn sorts by count (highest first)
ps -e -o user= | sort | uniq -c | sort -rn | head -n 5 | while read count user; do
    echo "    $user: $count processes"
done

# ---- 4. Find specific processes ----
echo ""
echo "=== 4. Finding Specific Processes ==="

# pgrep searches for processes by name
# It returns the PID(s) of matching processes
echo "  Looking for 'bash' processes:"
BASH_PIDS=$(pgrep bash 2>/dev/null)
if [[ -n "$BASH_PIDS" ]]; then
    echo "$BASH_PIDS" | while read pid; do
        # ps -p PID -o comm= shows just the command name for that PID
        CMD=$(ps -p "$pid" -o comm= 2>/dev/null)
        echo "    PID $pid: $CMD"
    done
else
    echo "    No bash processes found"
fi

# Alternative: grep through ps aux output
# The grep -v grep at the end removes the grep command itself from results
echo ""
echo "  Search with ps aux | grep:"
ps aux | grep bash | grep -v grep | head -n 3 | sed 's/^/    /'

# ---- 5. Background execution demo ----
echo ""
echo "=== 5. Background Execution ==="

# The & at the end of a command sends it to the background
# The terminal remains available while the command runs
echo "  Starting a background sleep (3 seconds)..."
sleep 3 &
BG_PID=$!
# $! contains the PID of the last background process
echo "  Background PID: $BG_PID"

# jobs lists background jobs in the current shell
echo "  Current jobs:"
jobs 2>/dev/null | sed 's/^/    /'

# Wait for it to finish
wait $BG_PID 2>/dev/null
echo "  Background sleep finished"

# ---- 6. Exit codes ----
echo ""
echo "=== 6. Exit Codes (\$?) ==="

# Every command sets $? to its exit code after execution
# 0 = success, nonzero = some kind of failure

# Success case
ls / > /dev/null 2>&1
echo "  ls / (valid path):   exit code = $?"

# Failure case
ls /nonexistent_path > /dev/null 2>&1
echo "  ls /nonexistent:     exit code = $?"

# grep: exit 0 if found, exit 1 if not found, exit 2 if error
echo "hello" | grep -q "hello"
echo "  grep 'hello' (found):    exit code = $?"

echo "hello" | grep -q "xyz"
echo "  grep 'xyz' (not found):  exit code = $?"

# Using exit codes with && and ||
echo ""
echo "  Conditional execution with && and ||:"
ls / > /dev/null 2>&1 && echo "    ls / succeeded (&&)"
ls /nonexistent > /dev/null 2>&1 || echo "    ls /nonexistent failed (||)"

# ---- 7. Process survival cheatsheet ----
echo ""
echo "=== 7. Process Survival Reference ==="
echo ""
echo "  How to keep a process running after closing the terminal:"
echo ""
echo "  Method 1: nohup (no hangup)"
echo "    nohup long_command > output.log 2> error.log &"
echo "    Then close the terminal. Process keeps running."
echo ""
echo "  Method 2: Ctrl+Z then bg then disown"
echo "    1. Run command: long_command"
echo "    2. Press Ctrl+Z (suspends the process)"
echo "    3. Type: bg   (resumes in background)"
echo "    4. Type: disown  (detaches from terminal)"
echo "    Then close the terminal. Process keeps running."
echo ""
echo "  How to find and kill a process:"
echo "    pgrep -a sleep        # find PIDs matching 'sleep'"
echo "    kill 12345             # terminate process with PID 12345"
echo "    kill -9 12345          # force kill (if normal kill fails)"

echo ""
echo "=== Process Manager demo complete ==="
