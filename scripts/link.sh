#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# ---------------------------------------------------------------------------
# Shared utilities
# ---------------------------------------------------------------------------

# Link individual files (type=f) or directories (type=d) from source to target.
link_items() {
  local source_dir="$1" target_dir="$2" item_type="$3"
  mkdir -pv "$target_dir"
  for item in "$source_dir"/*; do
    local should_link=false
    [ "$item_type" = "f" ] && [ -f "$item" ] && should_link=true
    [ "$item_type" = "d" ] && [ -d "$item" ] && should_link=true
    if [ "$should_link" = true ]; then
      local target_path="$target_dir/$(basename "$item")"
      if [ -L "$target_path" ] && [ "$(readlink "$target_path")" = "$item" ]; then
        echo "  ✅ already linked: $(basename "$item")"
        continue
      fi
      ln -siv "$item" "$target_path"
      echo "  🔗 linked: $(basename "$item")"
    fi
  done
}

# Compose a SKILL.md: prepend metadata YAML as frontmatter, then emit the body.
compose_skill() {
  local body_file="$1" metadata_file="$2"
  printf -- "---\n"
  cat "$metadata_file"
  printf -- "---\n\n"
  cat "$body_file"
}

# Symlink all non-SKILL, non-dotfile assets from a skill dir into a target dir.
link_skill_assets() {
  local source_dir="$1" target_dir="$2"
  for item in "$source_dir"/*; do
    [ "$(basename "$item")" = "SKILL.md" ] && continue
    local target_path="$target_dir/$(basename "$item")"
    if [ -L "$target_path" ] && [ "$(readlink "$target_path")" = "$item" ]; then
      echo "    ✅ already linked: $(basename "$item")"
      continue
    fi
    ln -siv "$item" "$target_path"
    echo "    🔗 linked: $(basename "$item")"
  done
}

# ---------------------------------------------------------------------------
# Install functions — each guards on $PROVIDER
# ---------------------------------------------------------------------------

link_agents() {
  [[ "$PROVIDER" == "all" || "$PROVIDER" == "opencode" ]] || return 0
  echo "🤖 Linking agents..."
  link_items "$REPO_ROOT/.opencode/agents" "$HOME/.config/opencode/agents" "f"
  echo ""
}

link_skills() {
  echo "🧠 Linking skills..."
  local skills_dir="$REPO_ROOT/skills"
  for skill_dir in "$skills_dir"/*/; do
    [ -d "$skill_dir" ] || continue
    local skill_name
    skill_name="$(basename "$skill_dir")"

    if [[ ("$PROVIDER" == "all" || "$PROVIDER" == "opencode") && -f "$skill_dir/.opencode.metadata.yml" ]]; then
      local opencode_target="$HOME/.config/opencode/skills/$skill_name"
      [ -L "$opencode_target" ] && rm -v "$opencode_target"
      mkdir -p "$opencode_target"
      compose_skill "$skill_dir/SKILL.md" "$skill_dir/.opencode.metadata.yml" > "$opencode_target/SKILL.md"
      echo "  🪄 composed (opencode): $skill_name"
      link_skill_assets "$skill_dir" "$opencode_target"
    fi

    if [[ ("$PROVIDER" == "all" || "$PROVIDER" == "claude") && -f "$skill_dir/.claude.metadata.yml" ]]; then
      local claude_target="$HOME/.claude/skills/$skill_name"
      [ -L "$claude_target" ] && rm -v "$claude_target"
      mkdir -p "$claude_target"
      compose_skill "$skill_dir/SKILL.md" "$skill_dir/.claude.metadata.yml" > "$claude_target/SKILL.md"
      echo "  🪄 composed (claude): $skill_name"
      link_skill_assets "$skill_dir" "$claude_target"
    fi
  done
  echo ""
}

link_commands() {
  [[ "$PROVIDER" == "all" || "$PROVIDER" == "opencode" ]] || return 0
  echo "⚡️ Linking commands..."
  link_items "$REPO_ROOT/.opencode/commands" "$HOME/.config/opencode/commands" "f"
  echo ""
}

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Install agents, skills, and commands via symlinks into provider config dirs.
Flags are independent and combinable in any order. Defaults to all providers
and all types when no flags are given.

Provider (default: both):
  --opencode        Install for OpenCode (~/.config/opencode/)
  --claude          Install for Claude Code (~/.claude/)

Type (default: all):
  --agents          Agents only
  --skills          Skills only
  --commands        Commands only

Other:
  -h, --help        Show this help message

Examples:
  $(basename "$0")                     # all providers, all types
  $(basename "$0") --skills            # skills only, both providers
  $(basename "$0") --claude --skills   # Claude skills only
  $(basename "$0") --opencode          # all types, OpenCode only
EOF
}

PROVIDER="all"  # all | opencode | claude
TYPE="all"      # all | agents | skills | commands

while [[ $# -gt 0 ]]; do
  case "$1" in
    --opencode)  PROVIDER="opencode"; shift ;;
    --claude)    PROVIDER="claude";   shift ;;
    --agents)    TYPE="agents";       shift ;;
    --skills)    TYPE="skills";       shift ;;
    --commands)  TYPE="commands";     shift ;;
    -h|--help)   usage; exit 0 ;;
    *)
      echo "❌ Error: Unknown argument '$1'"
      echo "Run '$(basename "$0") --help' for usage."
      exit 1
      ;;
  esac
done

# ---------------------------------------------------------------------------
# Run
# ---------------------------------------------------------------------------

echo "✈️  runway clear and preparing for takeoff... 🛫"
echo ""

[[ "$TYPE" == "all" || "$TYPE" == "agents" ]]   && link_agents
[[ "$TYPE" == "all" || "$TYPE" == "skills" ]]   && link_skills
[[ "$TYPE" == "all" || "$TYPE" == "commands" ]] && link_commands

echo "🛫 runway installation complete! ✨🚀✨"
