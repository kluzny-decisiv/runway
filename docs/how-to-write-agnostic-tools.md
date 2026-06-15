# How to Write Provider-Agnostic Tools

Skills and commands in Runway follow the same directory convention: a shared body file contains the primary content, and provider-specific metadata files supply the frontmatter. When providers diverge significantly, the body itself can be forked per provider.

## Directory structure

```
<type>/<name>/
  SKILL.md or COMMAND.md        # shared body — no frontmatter, no provider-isms
  .claude.metadata.yml          # Claude Code frontmatter
  .opencode.metadata.yml        # OpenCode frontmatter
  SKILL.claude.md               # (optional) Claude-specific body fork
  SKILL.opencode.md             # (optional) OpenCode-specific body fork
  references/                   # (skills only) supplementary assets — symlinked at install time
```

`link.sh` composes the final installed file as:

```
--- <metadata> ---

<body>
```

Where `<body>` is the provider-specific fork if one exists, otherwise the shared body.

## Body files

`SKILL.md` and `COMMAND.md` are the canonical shared body. Write them as if no provider exists:

- No frontmatter (that lives entirely in `.metadata.yml`)
- No provider-specific syntax
- Phrase information-gathering steps as instructions the model should execute: `Run: git branch --show-current` — both Claude Code and OpenCode agents can call bash tools

If provider differences are limited to frontmatter (e.g. OpenCode needs `agent: general`), a single shared body is all you need.

## Metadata files

Each `.metadata.yml` file contains only YAML key-value pairs (no `---` delimiters — `link.sh` wraps them).

**Skills — recognized fields:**

| Provider | Fields |
|----------|--------|
| `.claude.metadata.yml` | `name`, `description`, `license` |
| `.opencode.metadata.yml` | `name`, `description`, `required_tools`, `license`, `metadata` |

**Commands — recognized fields:**

| Provider | Fields |
|----------|--------|
| `.claude.metadata.yml` | `description` |
| `.opencode.metadata.yml` | `description`, `agent` (always `general`) |

OpenCode commands require `agent: general`. Claude Code commands accept only `description:`.

## Forking the body

When a provider needs substantially different body content — different structure, different invocation patterns, different instructions — fork the body with a provider-specific file:

```
commands/draftpr/
  COMMAND.md               # shared body (used when no fork exists)
  COMMAND.claude.md        # Claude-specific fork
  COMMAND.opencode.md      # OpenCode-specific fork
  .claude.metadata.yml
  .opencode.metadata.yml
```

`link.sh` and `preview.sh` prefer the provider-specific fork over the shared body when composing. You can have a fork for one provider and fall back to the shared body for the other.

**When to fork vs. keep shared:**

| Situation | Approach |
|-----------|----------|
| Different frontmatter only | Shared body + provider `.metadata.yml` |
| Minor wording differences | Shared body (write generically) |
| Substantially different structure or instructions | Fork the body |

## Install targets

| Type | Provider | Target |
|------|----------|--------|
| Skill | Claude Code | `~/.claude/skills/<name>/SKILL.md` |
| Skill | OpenCode | `~/.config/opencode/skills/<name>/SKILL.md` |
| Command | Claude Code | `~/.claude/commands/<name>.md` |
| Command | OpenCode | `~/.config/opencode/commands/<name>.md` |

Skills that have a `references/` directory get it symlinked into the target — changes to reference files propagate immediately without re-running `link.sh`. Metadata or body changes require a re-run.

## Worked example: adding a new command

Suppose you want a `/standup` command that drafts a standup update from recent git activity. Both providers handle this the same way, so one shared body is enough:

```
commands/standup/
  COMMAND.md                  # "Run git log --since=yesterday and draft a standup..."
  .claude.metadata.yml        # description: Draft a standup update from recent commits
  .opencode.metadata.yml      # description: ...\nagent: general
```

If the OpenCode version needs a fundamentally different structure, add a fork:

```
  COMMAND.opencode.md         # OpenCode-specific version of the instructions
```

After creating the files, run:

```bash
./scripts/link.sh --commands
# restart your client(s)
```

Use `preview.sh` to verify the composed output before installing:

```bash
./scripts/preview.sh --command=standup             # both providers
./scripts/preview.sh --opencode --command=standup  # OpenCode only
```

## Checklist

- [ ] Body file has no frontmatter and no provider-specific syntax
- [ ] `.metadata.yml` files contain only valid YAML (no `---` delimiters)
- [ ] `./scripts/preview.sh` output looks correct for each provider
- [ ] `./scripts/link.sh` installs without errors
- [ ] `make lint` passes
- [ ] `README.md` updated if adding a new skill or command
