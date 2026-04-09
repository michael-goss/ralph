#!/bin/bash
set -e

RALPH_DIR="$(cd "$(dirname "$0")" && pwd)"
SANDBOX_NAME="ralph"

docker sandbox run "$SANDBOX_NAME" -- --add-dir "$RALPH_DIR"
