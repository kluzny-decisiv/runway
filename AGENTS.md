# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

Runway is a centralized store of AI agent definitions, skills, and commands for the OpenCode platform. Changes here propagate globally via symlinks — editing a file in `.opencode/agents/` immediately updates any globally installed instance.

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
- `.opencode/commands/` — Reusable commands invokable from the OpenCode UI
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

When writing skills, consult the provider docs for guidance:
- OpenCode: https://opencode.ai/docs/skills/
- Claude Code: https://claude.com/skills

Skills live in `./skills/<name>/` and are provider-agnostic. Each skill directory contains:

- **`SKILL.md`** — body content only (no frontmatter); shared across all providers
- **`.<provider>.metadata.yml`** — provider-specific frontmatter composed into the final `SKILL.md` at install time
- **`references/`** (optional) — supplementary docs symlinked into each provider's install target

### Provider metadata files

| File | Install target | Recognized fields |
|---|---|---|
| `.opencode.metadata.yml` | `~/.config/opencode/skills/<name>/` | `name`, `description`, `required_tools`, `license`, `metadata` |
| `.claude.metadata.yml` | `~/.claude/skills/<name>/` | `name`, `description`, `license` |

`link.sh` composes each `SKILL.md` as `frontmatter + body` when installing and symlinks `references/` (and any other assets) into the target directory. Changes to `SKILL.md` or metadata files take effect after re-running `link.sh`; changes to `references/` files propagate immediately via symlinks.

**acli** (`skills/acli/`) — Atlassian CLI reference for Jira operations. Default project: `PD` at `https://decisiv.atlassian.net/`. Contains command references for workitems, boards, sprints, and admin operations. Authentication is OAuth-only; destructive operations require confirmation.

## Commands

Command files (`.opencode/commands/*.md`) use YAML frontmatter (`agent: general`) plus a markdown body. Use `!` prefix to execute shell commands at invocation time — output is injected inline before the model runs:

```markdown
---
agent: general
---
Current branch: !`git branch --show-current`
```

**draftpr** — Drafts a PR summary by parsing the branch name for a Jira ticket ID, fetching ticket context via `acli`, and analyzing commits. Always shows a draft for user review before editing the PR or posting a comment. Never updates Jira tickets.

## Do

- Run `shellcheck scripts/link.sh` after editing the link script.
- Run `./scripts/link.sh` after modifying any skill, agent, or command to verify composition and linking end-to-end.
- Keep `README.md` in sync when adding new agents or skills — it is the user-facing summary.
- Put frontmatter exclusively in `.<provider>.metadata.yml` files. `SKILL.md` is body-only; frontmatter there will be treated as literal content.

## Don't

- Commit automatically. Halt after making changes and present a diff for review before staging anything.
- Edit installed files directly (e.g. `~/.config/opencode/skills/acli/SKILL.md`). Those are generated — edit the source in `skills/` and re-run `link.sh`.
- Symlink a skill directory wholesale. Skills require per-provider composition; symlinking bypasses frontmatter merging and installs the body-only `SKILL.md` without any frontmatter.
