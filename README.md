# Runway

Runway is a centralized repository of AI agents, skills, and commands. It supports multiple AI coding harnesses — install once, use everywhere.

## Supported Harnesses

| Harness | Agents | Skills | Commands |
|---------|--------|--------|----------|
| [OpenCode](https://opencode.ai) | ✅ | ✅ | ✅ |
| [Claude Code](https://claude.ai/code) | — | ✅ | — |

Skills are provider-agnostic: a shared body lives in `skills/<name>/SKILL.md` and provider-specific frontmatter in `skills/<name>/.<provider>.metadata.yml`. `link.sh` composes the final `SKILL.md` at install time. Agents and commands are currently OpenCode-only.

## Installation

```bash
./scripts/link.sh                     # all providers, all types
./scripts/link.sh --skills            # skills only (both providers)
./scripts/link.sh --claude --skills   # Claude Code skills only
./scripts/link.sh --opencode          # all types, OpenCode only
./scripts/link.sh --help              # full usage
```

To update after pulling:

```bash
git pull origin main && ./scripts/link.sh
# restart your client(s)
```

## Agents

Agents are OpenCode-only. Primary agents are invoked directly; subagents are orchestrated by primary agents via `@agentname`.

### Primary

| Agent | Description |
|-------|-------------|
| **python** | Senior Python engineer. Writes organized, extensible, secure, and performant Python. Orchestrates `@architect`, `@security`, and `@tdd`. |
| **rails** | Senior full-stack Rails developer. Framework-agnostic frontend, fluent in RSpec/Minitest. Orchestrates `@architect`, `@security`, and `@tdd`. |
| **derek** | Specializes in CSS, styling, and aesthetic coding. Refuses most technical tasks with comedic confusion but excels at looking really, really, really ridiculously good. |

### Subagents

| Agent | Description |
|-------|-------------|
| **architect** | Senior backend architect for scalable system design, database architecture, API development, and cloud infrastructure. |
| **security** | Expert security engineer for threat modeling, vulnerability assessment, and secure code review (OWASP). |
| **tdd** | Red-green-refactor TDD specialist. Writes integration-style tests and minimal implementation, focusing on behavior over implementation details. |

## Skills

Skills are available to all supported harnesses.

| Skill | Providers | Description |
|-------|-----------|-------------|
| **acli** | OpenCode, Claude Code | Atlassian CLI reference for Jira Cloud operations: work items, projects, boards, sprints, filters, and admin. Requires an authenticated `acli` binary. Default project: `PD` at `decisiv.atlassian.net`. |
