#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Extract information from JSON using pure bash/grep/sed
# Extract model.display_name
model_name=$(echo "$input" | grep -o '"display_name"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"display_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/' | head -n1)

# Extract context_window.used_percentage
used_pct=$(echo "$input" | grep -o '"used_percentage"[[:space:]]*:[[:space:]]*[0-9.]*' | sed 's/.*:[[:space:]]*\([0-9.]*\).*/\1/' | head -n1)

# Get conda environment (if active)
conda_env=""
if [ -n "$CONDA_DEFAULT_ENV" ]; then
    conda_env=$(printf " \e[01;33m(conda:%s)\e[00m" "$CONDA_DEFAULT_ENV")
fi

# Build model info string
model_info=""
if [ -n "$model_name" ] && [ "$model_name" != "null" ]; then
    model_info=$(printf " \e[01;35m[%s]\e[00m" "$model_name")
fi

# Build context usage string
context_info=""
if [ -n "$used_pct" ] && [ "$used_pct" != "null" ]; then
    context_info=$(printf " \e[01;36m[ctx:%d%%]\e[00m" "${used_pct%.*}")
fi

# Print the complete status line
# Format: user@host:directory (conda:env) [Model] [ctx:X%]
printf '\e[01;32m%s@%s\e[00m:\e[01;34m%s\e[00m%s%s%s\n' \
    "$(whoami)" \
    "$(hostname -s)" \
    "$(pwd)" \
    "$conda_env" \
    "$model_info" \
    "$context_info"
