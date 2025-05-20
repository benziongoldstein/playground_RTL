#!/bin/bash

# Update memory file from app directory
echo "Updating instruction memory file..."

# Get the workspace root directory
WORKSPACE_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
echo "Workspace root: $WORKSPACE_ROOT"

# Navigate to app directory and build the program
cd "$WORKSPACE_ROOT/app"
echo "Building program in $(pwd)"
make

# Generate or update inst_mem.sv if it doesn't exist yet
if [ ! -f "inst_mem.sv" ]; then
    echo "Creating inst_mem.sv from program.elf"
    riscv64-unknown-elf-objcopy --srec-len 1 --output-target=verilog program.elf inst_mem.sv
fi

# Copy the SystemVerilog memory file to the testbench directory
cp inst_mem.sv "$WORKSPACE_ROOT/verif/core/"
echo "Copied inst_mem.sv to $WORKSPACE_ROOT/verif/core/"

echo "Memory file updated successfully!" 