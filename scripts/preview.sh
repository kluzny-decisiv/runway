#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# shellcheck source=scripts/lib.sh
source "$SCRIPT_DIR/lib.sh"

# ---------------------------------------------------------------------------
# Usage
# ---------------------------------------------------------------------------

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Preview the composed output of a skill or command for a given provider.
Prints to stdout — no files are written or installed.

Provider (default: both):
  --opencode          Preview OpenCode output
  --claude            Preview Claude Code output

Artifact (required, one of):
  --skill=<name>      Compose from skills/<name>/
  --command=<name>    Compose from commands/<name>/

Other:
  -h, --help          Show this help message

Examples:
  $(basename "$0") --skill=acli                  # both providers
  $(basename "$0") --opencode --skill=acli       # OpenCode only
  $(basename "$0") --claude --command=draftpr    # Claude Code only
EOF
}

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------

PROVIDER="all"  # all | opencode | claude
TYPE=""         # skill | command
NAME=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --opencode)    PROVIDER="opencode"; shift ;;
    --claude)      PROVIDER="claude";   shift ;;
    --skill=*)     TYPE="skill";   NAME="${1#--skill=}";   shift ;;
    --command=*)   TYPE="command"; NAME="${1#--command=}"; shift ;;
    -h|--help)     usage; exit 0 ;;
    *)
      echo "❌ Error: Unknown argument '$1'"
      echo "Run '$(basename "$0") --help' for usage."
      exit 1
      ;;
  esac
done

if [ -z "$TYPE" ] || [ -z "$NAME" ]; then
  echo "❌ Error: --skill=<name> or --command=<name> is required"
  echo ""
  usage
  exit 1
fi

# ---------------------------------------------------------------------------
# Resolve paths
# ---------------------------------------------------------------------------

case "$TYPE" in
  skill)   SOURCE_DIR="$REPO_ROOT/skills/$NAME";   BODY="SKILL.md" ;;
  command) SOURCE_DIR="$REPO_ROOT/commands/$NAME"; BODY="COMMAND.md" ;;
  *)       echo "❌ Internal error: unknown type '$TYPE'"; exit 1 ;;
esac

if [ ! -d "$SOURCE_DIR" ]; then
  echo "❌ Error: $TYPE '$NAME' not found (expected $SOURCE_DIR)"
  exit 1
fi

# ---------------------------------------------------------------------------
# Preview
# ---------------------------------------------------------------------------

show_provider() {
  local provider="$1"
  local metadata="$SOURCE_DIR/.$provider.metadata.yml"
  if [ ! -f "$metadata" ]; then
    echo "(no $provider metadata for $TYPE '$NAME' — skipping)" >&2
    return
  fi
  local body
  body="$(resolve_body "$SOURCE_DIR" "$BODY" "$provider")"
  if [ ! -f "$body" ]; then
    echo "❌ Error: no body found for $TYPE '$NAME' ($provider)" >&2
    return 1
  fi
  compose_artifact "$body" "$metadata"
}

if [ "$PROVIDER" = "all" ]; then
  echo "=== opencode ==="
  show_provider "opencode" || true
  echo ""
  echo "=== claude ==="
  show_provider "claude" || true
else
  show_provider "$PROVIDER"
fi
