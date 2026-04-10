#!/bin/bash
set -e

RALPH_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Removing PRDs and issues from $RALPH_DIR..."
rm -rf "$RALPH_DIR/.prds"
rm -rf "$RALPH_DIR/.issues"
echo "Cleanup complete."
