#!/bin/bash
# Set MODEL_ROOT to the root of the current git repository
MODEL_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"
if [ -z "$MODEL_ROOT" ]; then
  echo "Error: Not inside a git repository."
  return 1  # Use 'exit 1' if running as a script, 'return 1' if sourcing
fi
export MODEL_ROOT
echo "MODEL_ROOT set to $MODEL_ROOT" 