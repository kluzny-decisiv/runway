#!/usr/bin/env bash

set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Link items from source directory to target directory
# Args: $1 = source dir, $2 = target dir, $3 = type (f for files, d for directories), $4 = item name (for display)
link_items() {
  local source_dir="$1"
  local target_dir="$2"
  local item_type="$3"
  local item_name="$4"
  
  echo "Linking $item_name..."
  mkdir -pv "$target_dir"
  
  for item in "$source_dir"/*; do
    local should_link=false
    if [ "$item_type" = "f" ] && [ -f "$item" ]; then
      should_link=true
    elif [ "$item_type" = "d" ] && [ -d "$item" ]; then
      should_link=true
    fi
    
    if [ "$should_link" = true ]; then
      echo "  -> $(basename "$item")"
      ln -si "$item" "$target_dir/$(basename "$item")"
    fi
  done
}

# Link agents
link_agents() {
  link_items "$REPO_ROOT/.opencode/agents" "$HOME/.config/opencode/agents" "f" "agents"
}

# Link skills
link_skills() {
  link_items "$REPO_ROOT/.opencode/skills" "$HOME/.config/opencode/skills" "d" "skills"
}

# Link commands
link_commands() {
  link_items "$REPO_ROOT/.opencode/commands" "$HOME/.config/opencode/commands" "f" "commands"
}

# Parse command line arguments
TARGET="${1:-all}"

case "$TARGET" in
  agents)
    link_agents
    ;;
  skills)
    link_skills
    ;;
  commands)
    link_commands
    ;;
  all)
    link_agents
    link_skills
    link_commands
    ;;
  *)
    echo "Error: Unknown target '$TARGET'"
    echo "Usage: $0 [agents|skills|commands|all]"
    exit 1
    ;;
esac

echo ""
echo "runway installation complete!"
