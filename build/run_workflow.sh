#!/bin/bash
# Simple script to run the workflow commands

# Navigate to project root (parent directory of this script)
cd "$(dirname "$0")/.."
PROJECT_ROOT=$(pwd)

# Create log directory if it doesn't exist
mkdir -p target/logs

# Generate timestamp for log file
TIMESTAMP=$(date "+%Y%m%d_%H%M%S")
LOG_FILE="$PROJECT_ROOT/target/logs/workflow_run_$TIMESTAMP.log"

# Start logging
echo "Running workflow commands from project root: $PROJECT_ROOT" | tee -a "$LOG_FILE"
echo "Full log file: $LOG_FILE"
echo -e "\n=== Running build steps from workflow ===\n" >> "$LOG_FILE"

# Traffic Light IP
echo -e "\nRunning: Build traffic_light IP" >> "$LOG_FILE"
echo "Command: python3 build/builder.py traffic_light -hw -sim" >> "$LOG_FILE"
python3 build/builder.py traffic_light -hw -sim >> "$LOG_FILE" 2>&1
if [ $? -eq 0 ]; then
  echo "Status: ✅ PASSED" >> "$LOG_FILE"
  passed="traffic_light"
else
  echo "Status: ❌ FAILED" >> "$LOG_FILE"
  failed="traffic_light"
fi

# Register File IP
echo -e "\nRunning: Build rf IP (Register File)" >> "$LOG_FILE"
echo "Command: python3 build/builder.py rf -hw -sim" >> "$LOG_FILE"
python3 build/builder.py rf -hw -sim >> "$LOG_FILE" 2>&1
if [ $? -eq 0 ]; then
  echo "Status: ✅ PASSED" >> "$LOG_FILE"
  passed="$passed rf"
else
  echo "Status: ❌ FAILED" >> "$LOG_FILE"
  failed="$failed rf"
fi

# Program Counter IP
echo -e "\nRunning: Build pc IP (Program Counter)" >> "$LOG_FILE"
echo "Command: python3 build/builder.py pc -hw -sim" >> "$LOG_FILE"
python3 build/builder.py pc -hw -sim >> "$LOG_FILE" 2>&1
if [ $? -eq 0 ]; then
  echo "Status: ✅ PASSED" >> "$LOG_FILE"
  passed="$passed pc"
else
  echo "Status: ❌ FAILED" >> "$LOG_FILE"
  failed="$failed pc"
fi

# ALU IP
echo -e "\nRunning: Build alu IP" >> "$LOG_FILE"
echo "Command: python3 build/builder.py alu -hw -sim" >> "$LOG_FILE"
python3 build/builder.py alu -hw -sim >> "$LOG_FILE" 2>&1
if [ $? -eq 0 ]; then
  echo "Status: ✅ PASSED" >> "$LOG_FILE"
  passed="$passed alu"
else
  echo "Status: ❌ FAILED" >> "$LOG_FILE"
  failed="$failed alu"
fi

# Print summary both to log and screen
echo -e "\n=== Build Summary ===" | tee -a "$LOG_FILE"
if [ -z "$passed" ]; then
  echo "Passed: 0 - None" | tee -a "$LOG_FILE"
else
  echo "Passed: $(echo $passed | wc -w) - $passed" | tee -a "$LOG_FILE"
fi

if [ -z "$failed" ]; then
  echo "Failed: 0 - None" | tee -a "$LOG_FILE"
  echo "All builds passed successfully" | tee -a "$LOG_FILE"
  echo "Log file: $LOG_FILE"
  exit 0
else
  echo "Failed: $(echo $failed | wc -w) - $failed" | tee -a "$LOG_FILE"
  echo "Some builds failed" | tee -a "$LOG_FILE"
  echo "Log file: $LOG_FILE"
  exit 1
fi 