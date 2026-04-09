#!/bin/bash
set -e

RALPH_DIR="$(cd "$(dirname "$0")" && pwd)"
SANDBOX_NAME="ralph"
ITERATIONS=${1:-50}

for ((i=1; i<=$ITERATIONS; i++)); do
  echo "=== Ralph iteration $i/$ITERATIONS ==="

  result=$(docker sandbox run "$SANDBOX_NAME" -- --add-dir "$RALPH_DIR" -p "$(cat "$RALPH_DIR/PROMPT.md")")

  echo "$result"

  if [[ "$result" == *"<promise>COMPLETE</promise>"* ]]; then
    echo "All issues done, exiting."
    exit 0
  fi
done
