#!/bin/bash
# Set MODEL_ROOT to the directory containing this script's parent (the project root)
export MODEL_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
echo "MODEL_ROOT set to $MODEL_ROOT" 