#!/bin/bash
# Simple script to run the workflow commands

# Navigate to project root (parent directory of this script)
cd "$(dirname "$0")/.."
echo "Running workflow commands from project root: $(pwd)"

# Run each build command directly from the workflow file
echo -e "\n=== Running build steps from workflow ===\n"

# Traffic Light IP
echo -e "\nRunning: Build traffic_light IP"
echo "Command: python3 build/builder.py traffic_light -hw -sim"
python3 build/builder.py traffic_light -hw -sim
if [ $? -eq 0 ]; then
  echo "Status: ✅ PASSED"
  passed="traffic_light"
else
  echo "Status: ❌ FAILED"
  failed="traffic_light"
fi

# Register File IP
echo -e "\nRunning: Build rf IP (Register File)"
echo "Command: python3 build/builder.py rf -hw -sim"
python3 build/builder.py rf -hw -sim
if [ $? -eq 0 ]; then
  echo "Status: ✅ PASSED"
  passed="$passed rf"
else
  echo "Status: ❌ FAILED"
  failed="$failed rf"
fi

# Program Counter IP
echo -e "\nRunning: Build pc IP (Program Counter)"
echo "Command: python3 build/builder.py pc -hw -sim"
python3 build/builder.py pc -hw -sim
if [ $? -eq 0 ]; then
  echo "Status: ✅ PASSED"
  passed="$passed pc"
else
  echo "Status: ❌ FAILED"
  failed="$failed pc"
fi

# ALU IP
echo -e "\nRunning: Build alu IP"
echo "Command: python3 build/builder.py alu -hw -sim"
python3 build/builder.py alu -hw -sim
if [ $? -eq 0 ]; then
  echo "Status: ✅ PASSED"
  passed="$passed alu"
else
  echo "Status: ❌ FAILED"
  failed="$failed alu"
fi

# Print summary
echo -e "\n=== Build Summary ==="
if [ -z "$passed" ]; then
  echo "Passed: 0 - None"
else
  echo "Passed: $(echo $passed | wc -w) - $passed"
fi

if [ -z "$failed" ]; then
  echo "Failed: 0 - None"
  echo "All builds passed successfully"
  exit 0
else
  echo "Failed: $(echo $failed | wc -w) - $failed"
  echo "Some builds failed"
  exit 1
fi 