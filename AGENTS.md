# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

Runway is a centralized store of AI agent definitions, skills, and commands for multiple AI coding harnesses. Changes propagate globally via `link.sh` — re-run it after any edit and restart your client.

## Installation & Updating

```bash
./scripts/link.sh                        # all providers, all types
./scripts/link.sh --skills               # skills only (both providers)
./scripts/link.sh --claude --skills      # Claude skills only
./scripts/link.sh --opencode             # all types, OpenCode only
```

Flags are independent and combinable in any order. `--opencode` and `--claude` default to both; `--agents`, `--skills`, `--commands` default to all three.

To update after pulling changes:

```bash
git pull origin main && ./scripts/link.sh
# then restart your client(s)
```

The script skips items that are already correctly symlinked.

## Directory Structure

- `.opencode/agents/` — Agent definitions (YAML frontmatter + markdown instructions)
- `commands/` — Provider-agnostic commands (see Commands section)
- `skills/` — Provider-agnostic skill packs (see Skills section)
- `scripts/link.sh` — Installation script

## Agent Architecture

Agent files use YAML frontmatter to configure behavior. Key frontmatter fields:

```yaml
description: "One-line description shown in agent picker"
mode: primary          # primary = user-invokable; omit for subagents
model: github-copilot/claude-sonnet-4.5
temperature: 0.2
tools:
  write: true
  edit: true
  bash: true
  read: true
  grep: true
  glob: true
  task: true
  webfetch: false
permission:
  bash:
    "*": "ask"              # default: prompt
    "git log*": "allow"     # specific pattern: auto-allow
color: "#3776AB"            # hex color for the agent chip (primary agents only)
```

Two categories:

**Primary agents** (invoke these directly):
- `python.md` — Senior Python engineer; orchestrates architect, security, and tdd subagents
- `rails.md` — Senior full-stack Rails developer; orchestrates architect, security, and tdd subagents
- `derek.md` — Design/CSS specialist; not suited for general engineering tasks

**Subagents** (orchestrated by primary agents via `@agentname`, not invoked directly):
- `architect.md` — Scalable system design, database architecture, API development
- `security.md` — Threat modeling, vulnerability assessment, secure code review (OWASP)
- `tdd.md` — Red-green-refactor TDD; writes integration-style tests and minimal implementation

## Skills

Skills and commands use the same directory convention — see [`docs/how-to-write-agnostic-tools.md`](docs/how-to-write-agnostic-tools.md) for the full authoring guide. For provider-specific docs:
- OpenCode: https://opencode.ai/docs/skills/
- Claude Code: https://claude.com/skills

Each skill lives in `skills/<name>/` and contains:

- **`SKILL.md`** — shared body (no frontmatter); shared across all providers
- **`SKILL.<provider>.md`** (optional) — provider-specific body fork; used instead of `SKILL.md` when it exists
- **`.<provider>.metadata.yml`** — provider-specific frontmatter composed into the final `SKILL.md` at install time
- **`references/`** (optional) — supplementary docs symlinked into each provider's install target

### Provider metadata fields

| File | Install target | Recognized fields |
|---|---|---|
| `.opencode.metadata.yml` | `~/.config/opencode/skills/<name>/` | `name`, `description`, `required_tools`, `license`, `metadata` |
| `.claude.metadata.yml` | `~/.claude/skills/<name>/` | `name`, `description`, `license` |

`link.sh` composes each `SKILL.md` as `frontmatter + body` when installing (preferring the provider fork if present) and symlinks `references/` (and any other assets) into the target directory. Changes to `SKILL.md` or metadata files take effect after re-running `link.sh`; changes to `references/` files propagate immediately via symlinks.

**acli** (`skills/acli/`) — Atlassian CLI reference for Jira operations. Default project: `PD` at `https://decisiv.atlassian.net/`. Contains command references for workitems, boards, sprints, and admin operations. Authentication is OAuth-only; destructive operations require confirmation.

## Commands

Commands and skills use the same directory convention — see [`docs/how-to-write-agnostic-tools.md`](docs/how-to-write-agnostic-tools.md) for the full authoring guide.

Each command lives in `commands/<name>/` and contains:

- **`COMMAND.md`** — shared body (no frontmatter, no provider-specific syntax)
- **`COMMAND.<provider>.md`** (optional) — provider-specific body fork; used instead of `COMMAND.md` when it exists
- **`.<provider>.metadata.yml`** — provider frontmatter composed in at install time

`link.sh` composes `frontmatter + body` (preferring the provider fork when present) and writes the result to:
- Claude Code: `~/.claude/commands/<name>.md`
- OpenCode: `~/.config/opencode/commands/<name>.md`

### Provider metadata fields

| Provider | Fields |
|----------|--------|
| `.claude.metadata.yml` | `description` |
| `.opencode.metadata.yml` | `description`, `agent` (always `general`) |

### Available commands

**draftpr** (`commands/draftpr/`) — Drafts a PR summary by parsing the branch name for a Jira ticket ID, fetching ticket context via `acli`, and analyzing commits. Always shows a draft for user review before editing the PR or posting a comment. Never updates Jira tickets.

## Do

- Run `make lint` after editing any script — it shellchecks everything in `scripts/`.
- Run `./scripts/preview.sh` to verify composed output before installing.
- Run `./scripts/link.sh` after modifying any skill, agent, or command to install changes.
- Keep `README.md` in sync when adding new agents, skills, or commands — it is the user-facing summary.
- Put frontmatter exclusively in `.<provider>.metadata.yml` files. `SKILL.md` and `COMMAND.md` are body-only; frontmatter there will be treated as literal content.
- See `docs/how-to-write-agnostic-tools.md` for the full authoring guide when creating new skills or commands.

## Don't

- Commit automatically. Halt after making changes and present a diff for review before staging anything.
- Edit installed files directly (e.g. `~/.config/opencode/skills/acli/SKILL.md`, `~/.claude/commands/draftpr.md`). Those are generated — edit the source in `skills/` or `commands/` and re-run `link.sh`.
- Symlink a skill directory wholesale. Skills require per-provider composition; symlinking bypasses frontmatter merging and installs the body-only `SKILL.md` without any frontmatter.
