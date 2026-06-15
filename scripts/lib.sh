#!/usr/bin/env bash
# Shared helpers for link.sh and preview.sh

# Compose a provider-specific file: frontmatter from metadata_file, then body.
compose_artifact() {
  local body_file="$1" metadata_file="$2"
  printf -- "---\n"
  cat "$metadata_file"
  printf -- "---\n\n"
  cat "$body_file"
}

# Return the body file to use for a given provider: the provider-specific fork
# (e.g. SKILL.claude.md) if it exists, otherwise the shared body (e.g. SKILL.md).
resolve_body() {
  local dir="$1" body="$2" provider="$3"
  local stem="${body%.*}"
  local fork="$dir/$stem.$provider.md"
  if [ -f "$fork" ]; then
    echo "$fork"
  else
    echo "$dir/$body"
  fi
}
