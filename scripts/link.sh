#!/usr/bin/env bash

set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Create the global agents directory
mkdir -pv "$HOME/.config/opencode/agents"

# Create symlinks for each agent file
for agent in "$REPO_ROOT/.opencode/agents"/*; do
  if [ -f "$agent" ]; then
    ln -si "$agent" "$HOME/.config/opencode/agents/$(basename "$agent")"
  fi
done

echo "runway installation complete!"
