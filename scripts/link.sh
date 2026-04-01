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

# Create the global skills directory
mkdir -pv "$HOME/.config/opencode/skills"

# Create symlinks for each skill folder
for skill in "$REPO_ROOT/.opencode/skills"/*; do
  if [ -d "$skill" ]; then
    ln -si "$skill" "$HOME/.config/opencode/skills/$(basename "$skill")"
  fi
done

# Create the global commands directory
mkdir -pv "$HOME/.config/opencode/commands"

# Create symlinks for each command file
for command in "$REPO_ROOT/.opencode/commands"/*; do
  if [ -f "$command" ]; then
    ln -si "$command" "$HOME/.config/opencode/commands/$(basename "$command")"
  fi
done

echo "runway installation complete!"
