#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# shellcheck source=scripts/lib.sh
source "$SCRIPT_DIR/lib.sh"

# ---------------------------------------------------------------------------
# Removal helpers
# ---------------------------------------------------------------------------

# Remove symlinks in target_dir whose readlink points into source_dir.
unlink_items() {
  local source_dir="$1" target_dir="$2"
  [ -d "$target_dir" ] || return 0
  for item in "$source_dir"/*; do
    [ -e "$item" ] || continue
    local target_path
    target_path="$target_dir/$(basename "$item")"
    if [ -L "$target_path" ] && [ "$(readlink "$target_path")" = "$item" ]; then
      rm -v "$target_path"
      echo "  🗑️  removed: $(basename "$item")"
    fi
  done
}

# Remove a composed artifact directory (skill) for one provider.
# Removes the composed body file, asset symlinks that point back into source_dir,
# and the target directory itself if it ends up empty.
uninstall_artifact() {
  local source_dir="$1" target_dir="$2" body_file="$3" provider="$4" name="$5"
  local metadata="$source_dir/.$provider.metadata.yml"
  [ -f "$metadata" ] || return 0
  [ -d "$target_dir" ]  || return 0

  # Remove the composed body file only if its content matches what we would have written.
  local composed="$target_dir/$body_file"
  if [ -f "$composed" ] && [ ! -L "$composed" ]; then
    local body
    body="$(resolve_body "$source_dir" "$body_file" "$provider")"
    if [ -f "$body" ] && diff -q "$composed" <(compose_artifact "$body" "$metadata") > /dev/null 2>&1; then
      rm -v "$composed"
    else
      echo "  ⚠️  skipped ($provider): $name — installed file differs from current source, not removing"
      return 0
    fi
  fi

  # Remove asset symlinks that point back into this source dir.
  for item in "$target_dir"/*; do
    [ -e "$item" ] || [ -L "$item" ] || continue
    if [ -L "$item" ] && [[ "$(readlink "$item")" == "$source_dir/"* ]]; then
      rm -v "$item"
    fi
  done

  # Remove the target dir if now empty.
  if [ -d "$target_dir" ] && [ -z "$(ls -A "$target_dir")" ]; then
    rmdir -v "$target_dir"
  fi

  echo "  🗑️  removed ($provider): $name"
}

# Remove a composed command file for one provider, only if content matches our source.
uninstall_command() {
  local source_dir="$1" target_file="$2" provider="$3" name="$4"
  local metadata="$source_dir/.$provider.metadata.yml"
  [ -f "$metadata" ] || return 0
  [ -f "$target_file" ] && [ ! -L "$target_file" ] || return 0

  local body
  body="$(resolve_body "$source_dir" "COMMAND.md" "$provider")"
  if [ -f "$body" ] && diff -q "$target_file" <(compose_artifact "$body" "$metadata") > /dev/null 2>&1; then
    rm -v "$target_file"
    echo "  🗑️  removed ($provider): $name"
  else
    echo "  ⚠️  skipped ($provider): $name — installed file differs from current source, not removing"
  fi
}

# ---------------------------------------------------------------------------
# Uninstall functions — each guards on $PROVIDER
# ---------------------------------------------------------------------------

unlink_agents() {
  [[ "$PROVIDER" == "all" || "$PROVIDER" == "opencode" ]] || return 0
  echo "🤖 Unlinking agents..."
  unlink_items "$REPO_ROOT/.opencode/agents" "$HOME/.config/opencode/agents"
  echo ""
}

unlink_skills() {
  echo "🧠 Unlinking skills..."
  local skills_dir="$REPO_ROOT/skills"
  for skill_dir in "$skills_dir"/*/; do
    [ -d "$skill_dir" ] || continue
    local skill_name
    skill_name="$(basename "$skill_dir")"
    if [[ "$PROVIDER" == "all" || "$PROVIDER" == "opencode" ]]; then
      uninstall_artifact "$skill_dir" "$HOME/.config/opencode/skills/$skill_name" \
        "SKILL.md" "opencode" "$skill_name"
    fi
    if [[ "$PROVIDER" == "all" || "$PROVIDER" == "claude" ]]; then
      uninstall_artifact "$skill_dir" "$HOME/.claude/skills/$skill_name" \
        "SKILL.md" "claude" "$skill_name"
    fi
  done
  echo ""
}

unlink_commands() {
  echo "⚡️ Unlinking commands..."
  local commands_dir="$REPO_ROOT/commands"
  for cmd_dir in "$commands_dir"/*/; do
    [ -d "$cmd_dir" ] || continue
    local cmd_name
    cmd_name="$(basename "$cmd_dir")"
    [[ "$PROVIDER" == "all" || "$PROVIDER" == "claude" ]]   && \
      uninstall_command "$cmd_dir" "$HOME/.claude/commands/$cmd_name.md"             "claude"   "$cmd_name"
    [[ "$PROVIDER" == "all" || "$PROVIDER" == "opencode" ]] && \
      uninstall_command "$cmd_dir" "$HOME/.config/opencode/commands/$cmd_name.md"   "opencode" "$cmd_name"
  done
  echo ""
}

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Remove agents, skills, and commands previously installed by link.sh.
Flags are independent and combinable in any order. Defaults to all providers
and all types when no flags are given.

Provider (default: both):
  --opencode        Uninstall for OpenCode (~/.config/opencode/)
  --claude          Uninstall for Claude Code (~/.claude/)

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

echo "✈️  runway preparing to unlink... 🛬"
echo ""

[[ "$TYPE" == "all" || "$TYPE" == "agents" ]]   && unlink_agents
[[ "$TYPE" == "all" || "$TYPE" == "skills" ]]   && unlink_skills
[[ "$TYPE" == "all" || "$TYPE" == "commands" ]] && unlink_commands

echo "🛬 runway uninstall complete."
