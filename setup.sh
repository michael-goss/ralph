#!/bin/bash
set -e

RALPH_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$RALPH_DIR/.." && pwd)"
SANDBOX_NAME="ralph"

echo "Creating sandbox '$SANDBOX_NAME' with workspace $REPO_ROOT..."
docker sandbox create --name "$SANDBOX_NAME" claude "$REPO_ROOT"
echo "Installing Ralph permission settings into sandbox user config..."
docker sandbox exec -i "$SANDBOX_NAME" bash -c 'mkdir -p /home/agent/.claude && cat > /home/agent/.claude/settings.json' < "$RALPH_DIR/.claude/settings.json"
echo "Sandbox created. Running Claude to trigger OAuth flow..."
docker sandbox run "$SANDBOX_NAME" -- --add-dir "$RALPH_DIR"
echo "OAuth complete. Installing pnpm and dependencies..."
docker sandbox exec ralph bash -c "sudo corepack enable && corepack prepare pnpm@10.28.1 --activate && cd $REPO_ROOT && CI=true pnpm install --frozen-lockfile"
echo "Setup complete. Run ralph.sh to start the loop."
