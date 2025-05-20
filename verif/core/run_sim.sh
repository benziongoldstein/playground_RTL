#!/bin/bash

# Run simulation for core testbench
echo "Running core simulation..."

# Get the workspace root directory
WORKSPACE_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
echo "Workspace root: $WORKSPACE_ROOT"

# First update the memory file
./update_mem.sh

# Create output directory if it doesn't exist
mkdir -p "$WORKSPACE_ROOT/target/core"

# Run iverilog simulation
cd "$WORKSPACE_ROOT"
iverilog -g2012 -f verif/core/core_list.f -o target/core/core_tb.vvp
vvp target/core/core_tb.vvp

# If gtkwave exists, open the waveform
if command -v gtkwave >/dev/null 2>&1; then
    echo "Opening waveform in GTKWave..."
    gtkwave target/core/core.vcd &
else
    echo "GTKWave not found. Skipping waveform viewing."
fi

echo "Simulation completed!" 