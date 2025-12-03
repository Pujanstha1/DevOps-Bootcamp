## Assignment 3: 
### A DevOps Engineer wants to track the top CPU-consuming process.
**Tasks**:
Write a script that:
Identifies the `PID` using the most `CPU Logs` its `PID`, `process name`, and `CPU usage` to `cpu_report`.txt

### Step 1: First we create a directory named `scripts`
```
mkdir -p ~/scripts
cd ~/scripts
```
### Step 2: Create and open `cpu_monitor.sh` with editor.
```
nano cpu_monitor.sh
```
### Step 3: In the editor, we write the following commands:
```
#!/bin/bash

# Script: cpu_monitor.sh
# Purpose: Logs top 5 CPU-consuming processes

LOGFILE="cpu_report.txt"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

TOP_PROCESS=$(ps -eo pid,comm,%cpu --sort=-%cpu | sed -n '2,6p')

PID=$(echo $TOP_PROCESS | awk '{print $1}')
PNAME=$(echo $TOP_PROCESS | awk '{print $2}')
CPU=$(echo $TOP_PROCESS | awk '{print $3}')

echo "[$TIMESTAMP] PID: $PID | Process: $PNAME | CPU: $CPU%" >> $LOGFILE
```

### Explanation to the above script:
1. **Bash Shell**

`#~/bin/bash`: 
- Tells Linux that this script must be executed using bash shell.
- Every shell script usually starts with this.

2. **Define the logfile name**

`LOGFILE="cpu_report.txt"`:
- Creates a variable named LOGFILE
- It stores the filename where results will be written.
- Using a variable makes it easier to change the filename later.

3. Get the correct Date & Time

`TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")`:
- `date` → prints current date/time
- `"+%Y-%m-%d %H:%M:%S"` → format (Year-Month-Day Hour:Min:Sec)
- `$( ... )` → captures the output of a command and stores it in a variable.

4. **Get the top CPU-consuming process**

`TOP_PROCESS=$(ps -eo pid,comm,%cpu --sort=-%cpu | sed -n 2p)`:

a. `ps -eo pid,comm,%cpu`: 

- `pid` → process ID
- `comm` → name of command
- `%cpu` → CPU usage

b. Sorting
`--sort=-%cpu`:
- Sorts the processes in ****descending order**
- Highest CPU at the top

c. Use sed to get the 2-6 line
`sed -n '2,6p'`:
- Line 1 is the header (PID, COMMAND, %CPU)
- Line 2 is the top CPU-consuming process
- So `sed -n '2,6p'` prints line 2 to 6.

d. The entire output is stored in:
`TOP_PROCESS`

5. **Extract PID**: `PID=$(echo $TOP_PROCESS | awk '{print $1}')`
- echo $TOP_PROCESS prints the line
- awk '{print $1}' prints first column → the PID
- First Column
6. **6. Extract Process Name**: `PNAME=$(echo $TOP_PROCESS | awk '{print $2}')`
- Second Column
7. **Extract CPU Usage**: `CPU=$(echo $TOP_PROCESS | awk '{print $3}')`
- Third Column
8. **Log everything**: `echo "[$TIMESTAMP] PID: $PID | Process: $PNAME | CPU: $CPU%" >> $LOGFILE`
- `echo` → prints a line
- `>>` → appends to the file (does NOT overwrite)
- `$LOGFILE` → writes to cpu_report.txt

**Example Output**:
`[2025-11-20 15:10:33] PID: 1123 | Process: firefox | CPU: 45.6%`

---
### Step 4: Make the Script Executable: `chmod +x cpu_monitor.sh`

### Step 5: Run the Script: `./cpu_monitor.sh`
- This will create or update the file `cpu_report.txt`
---
### Overview
- Script gets current date/time
- Finds the process using the most CPU
- Extracts its PID, name, and CPU percentage
- Writes them into cpu_report.txt