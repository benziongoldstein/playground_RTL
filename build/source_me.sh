#!/bin/bash
# Source this script to set MODEL_ROOT to the root of your git repo
export MODEL_ROOT=$(git rev-parse --show-toplevel)
echo "MODEL_ROOT set to $MODEL_ROOT" 