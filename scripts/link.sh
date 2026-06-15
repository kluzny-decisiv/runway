#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# shellcheck source=scripts/lib.sh
source "$SCRIPT_DIR/lib.sh"

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
      local target_path
      target_path="$target_dir/$(basename "$item")"
      if [ -L "$target_path" ] && [ "$(readlink "$target_path")" = "$item" ]; then
        echo "  ✅ already linked: $(basename "$item")"
        continue
      fi
      ln -siv "$item" "$target_path"
      echo "  🔗 linked: $(basename "$item")"
    fi
  done
}

# Symlink non-body, non-dotfile assets from a source dir into a target dir.
# Skips the shared body (e.g. SKILL.md) and any provider-specific body forks
# (e.g. SKILL.claude.md, SKILL.opencode.md) — those are composed, not linked.
link_assets() {
  local source_dir="$1" target_dir="$2" body_filename="$3"
  local stem="${body_filename%.*}"
  for item in "$source_dir"/*; do
    [ -e "$item" ] || continue
    local base; base="$(basename "$item")"
    [[ "$base" == .* ]] && continue
    [ "$base" = "$body_filename" ] && continue
    [[ "$base" == "$stem".*.md ]] && continue
    local target_path
    target_path="$target_dir/$base"
    if [ -L "$target_path" ] && [ "$(readlink "$target_path")" = "$item" ]; then
      echo "    ✅ already linked: $base"
      continue
    fi
    ln -siv "$item" "$target_path"
    echo "    🔗 linked: $base"
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

# Install a directory-based artifact (skill) for one provider.
# Usage: install_artifact <source_dir> <target_dir> <body_file> <provider> <name>
install_artifact() {
  local source_dir="$1" target_dir="$2" body_file="$3" provider="$4" name="$5"
  local metadata="$source_dir/.$provider.metadata.yml"
  [ -f "$metadata" ] || return 0

  local body
  body="$(resolve_body "$source_dir" "$body_file" "$provider")"
  [ -L "$target_dir" ] && rm -v "$target_dir"
  [ -f "$target_dir" ] && rm -v "$target_dir"
  mkdir -p "$target_dir"
  compose_artifact "$body" "$metadata" > "$target_dir/$body_file"
  echo "  🪄 composed ($provider): $name"
  link_assets "$source_dir" "$target_dir" "$body_file"
}

# Install a flat-file command for one provider.
# Usage: install_command <source_dir> <target_file> <provider> <name>
install_command() {
  local source_dir="$1" target_file="$2" provider="$3" name="$4"
  local metadata="$source_dir/.$provider.metadata.yml"
  [ -f "$metadata" ] || return 0

  local body
  body="$(resolve_body "$source_dir" "COMMAND.md" "$provider")"
  if [ ! -f "$body" ]; then
    echo "❌ Error: no body found for command '$name' ($provider)" >&2
    return 1
  fi
  [ -L "$target_file" ] && rm -v "$target_file"
  compose_artifact "$body" "$metadata" > "$target_file"
  echo "  🪄 composed ($provider): $name"
}

link_skills() {
  echo "🧠 Linking skills..."
  local skills_dir="$REPO_ROOT/skills"
  for skill_dir in "$skills_dir"/*/; do
    [ -d "$skill_dir" ] || continue
    local skill_name
    skill_name="$(basename "$skill_dir")"
    if [[ "$PROVIDER" == "all" || "$PROVIDER" == "opencode" ]]; then
      install_artifact "$skill_dir" "$HOME/.config/opencode/skills/$skill_name" \
        "SKILL.md" "opencode" "$skill_name"
    fi
    if [[ "$PROVIDER" == "all" || "$PROVIDER" == "claude" ]]; then
      install_artifact "$skill_dir" "$HOME/.claude/skills/$skill_name" \
        "SKILL.md" "claude" "$skill_name"
    fi
  done
  echo ""
}

link_commands() {
  echo "⚡️ Linking commands..."
  local commands_dir="$REPO_ROOT/commands"
  [[ "$PROVIDER" == "all" || "$PROVIDER" == "claude" ]]   && mkdir -p "$HOME/.claude/commands"
  [[ "$PROVIDER" == "all" || "$PROVIDER" == "opencode" ]] && mkdir -p "$HOME/.config/opencode/commands"
  for cmd_dir in "$commands_dir"/*/; do
    [ -d "$cmd_dir" ] || continue
    local cmd_name
    cmd_name="$(basename "$cmd_dir")"
    [[ "$PROVIDER" == "all" || "$PROVIDER" == "claude" ]]   && \
      install_command "$cmd_dir" "$HOME/.claude/commands/$cmd_name.md"              "claude"   "$cmd_name"
    [[ "$PROVIDER" == "all" || "$PROVIDER" == "opencode" ]] && \
      install_command "$cmd_dir" "$HOME/.config/opencode/commands/$cmd_name.md"    "opencode" "$cmd_name"
  done
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
