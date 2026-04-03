#!/bin/bash
set -e

# Resolve paths relative to this script (the ralph repo root)
RALPH_DIR="$(cd "$(dirname "$0")" && pwd)"

ITERATIONS=${1:-50}

for ((i=1; i<=$ITERATIONS; i++)); do
  echo "=== Ralph iteration $i/$ITERATIONS ==="

  result=$(docker sandbox run claude --add-dir "$RALPH_DIR/.claude" -- "$(cat "$RALPH_DIR/PROMPT.md")")

  echo "$result"

  if [[ "$result" == *"<promise>COMPLETE</promise>"* ]]; then
    echo "All issues done, exiting."
    exit 0
  fi
done
