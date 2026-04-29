#!/bin/bash
set -e

RALPH_DIR="$(cd "$(dirname "$0")" && pwd)"
SANDBOX_NAME="ralph"

docker sandbox run "$SANDBOX_NAME" -- --model claude-opus-4-6 --add-dir "$RALPH_DIR"
