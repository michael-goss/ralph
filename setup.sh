#!/bin/bash
set -e

RALPH_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$RALPH_DIR/.." && pwd)"
SANDBOX_NAME="ralph"

echo "Creating sandbox '$SANDBOX_NAME' with workspace $REPO_ROOT..."
docker sandbox create --name "$SANDBOX_NAME" claude "$REPO_ROOT"
echo "Installing Ralph permission settings into sandbox user config..."
docker sandbox exec -i "$SANDBOX_NAME" bash -c 'mkdir -p /home/agent/.claude && cat > /home/agent/.claude/settings.json' < "$RALPH_DIR/.claude/settings.json"
if [ -n "${NODE_VERSION}" ]; then
  echo "Installing Node.js ${NODE_VERSION}..."
  docker sandbox exec "$SANDBOX_NAME" bash -c "sudo npm install -g n && sudo n ${NODE_VERSION}"
fi
echo "Sandbox created. Running Claude to trigger OAuth flow..."
docker sandbox run "$SANDBOX_NAME" -- --add-dir "$RALPH_DIR"
echo "OAuth complete. Installing pnpm and dependencies..."
PNPM_VERSION="${PNPM_VERSION:-10.28.1}"
docker sandbox exec ralph bash -c "sudo corepack enable && corepack prepare pnpm@${PNPM_VERSION} --activate && cd $REPO_ROOT && CI=true pnpm install --frozen-lockfile"
echo "Setup complete. Run ralph.sh to start the loop."
