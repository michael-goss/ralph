#!/bin/bash
set -e

RALPH_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$RALPH_DIR/.." && pwd)"
SANDBOX_NAME="ralph"

echo "Creating sandbox '$SANDBOX_NAME' with workspace $REPO_ROOT..."
docker sandbox create --name "$SANDBOX_NAME" claude "$REPO_ROOT"
echo "Sandbox created. Running Claude to trigger OAuth flow..."
docker sandbox run "$SANDBOX_NAME"
echo "Setup complete. Run ralph.sh to start the loop."
