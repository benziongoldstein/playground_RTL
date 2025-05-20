#!/bin/bash

# Update memory file from app directory
echo "Updating instruction memory file..."

# Get the workspace root directory
WORKSPACE_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
echo "Workspace root: $WORKSPACE_ROOT"

# Check for -asm flag to determine build mode
ASM_MODE=0
if [ "$1" == "-asm" ]; then
    ASM_MODE=1
    echo "Using assembly-only mode"
fi

# Navigate to app directory
cd "$WORKSPACE_ROOT/app"
echo "Building program in $(pwd)"

if [ $ASM_MODE -eq 1 ]; then
    # Assembly-only mode
    echo "Building assembly test..."
    make clean
    make asm
else
    # Normal C+assembly mode
    echo "Building C program..."
    make clean
    make
fi

# Copy the SystemVerilog memory file to the testbench directory
cp inst_mem.sv "$WORKSPACE_ROOT/verif/core/"
echo "Copied inst_mem.sv to $WORKSPACE_ROOT/verif/core/"

echo "Memory file updated successfully!" 