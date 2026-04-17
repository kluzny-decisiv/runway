# Runway

Runway is a centralized repository for managing AI agents, models, commands, and tools. It provides a unified framework for organizing and deploying various AI components, enabling seamless integration and reusability across projects. Whether you're building conversational agents, implementing custom commands, or managing model configurations, Runway serves as the foundation for your AI development workflow.

## Primary Agents

| Agent | Description |
|-------|-------------|
| **python** | Senior Python engineer focused on writing organized, extensible, secure, and performant Python code. Orchestrates architect, security, and tdd subagents for comprehensive software development |
| **rails** | Senior full-stack Rails developer specializing in Ruby on Rails and JavaScript. Framework-agnostic frontend, fluent in RSpec/Minitest, writes organized, extensible, secure, and performant code |
| **derek** | Elite male model and angent who specializes in fashion, design, and aesthetic coding. Unable to perform most technical tasks but excels at CSS, styling, and looking really, really, really ridiculously good |

## Subagents

| Agent | Description |
|-------|-------------|
| **architect** | Senior backend architect specializing in scalable system design, database architecture, API development, and cloud infrastructure |
| **security** | Expert security engineer for threat modeling, vulnerability assessment, and secure code review |
| **tdd** | Test-Driven Development agent using red-green-refactor methodology. Writes integration-style tests and minimal implementation, focusing on behavior over implementation details |

## Skills

| Skill | Description |
|-------|-------------|
| **acli** | Reference guide for the Atlassian CLI - a command-line tool for interacting with Jira Cloud and Atlassian organization administration. Covers Jira operations (work items, projects, boards, sprints), user management, and automation workflows |

## Setup

**Note** the `-i` flag should prompt you before overwriting any existing files.

### Local Project Installation

Copy agents and skills to your project's `.opencode` directory:

```bash
git clone git@github.com:kluzny-decisiv/runway.git
cd runway
PROJECT_DIR=/path/to/your/project
mkdir -pv "$PROJECT_DIR/.opencode/agents"
mkdir -pv "$PROJECT_DIR/.opencode/skills"
cp -iv .opencode/agents/* "$PROJECT_DIR/.opencode/agents/"
cp -irv .opencode/skills/* "$PROJECT_DIR/.opencode/skills/"
```

### Global Installation

Create symlinks in your global OpenCode configuration directory:

```bash
mkdir -pv $HOME/.config/opencode/agents
mkdir -pv $HOME/.config/opencode/skills
for agent in .opencode/agents/*; do
  ln -si "$(pwd)/$agent" "$HOME/.config/opencode/agents/$(basename $agent)"
done
for skill in .opencode/skills/*; do
  ln -si "$(pwd)/$skill" "$HOME/.config/opencode/skills/$(basename $skill)"
done
```

This makes the agents and skills available to all OpenCode projects on your system.

Global installation can be perfomed by running `./scripts/link.sh`

### Updating

To update your globally installed agents and skills with the latest changes:

```bash
cd runway
git pull origin main
./scripts/link.sh
# restart your client
```

The symlinks will automatically reflect any updates made to the agent files in the repository.
