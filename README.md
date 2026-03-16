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

## Setup

**Note** the `-i` flag should prompt you before overwriting any existing files.

### Local Project Installation

Copy agents to your project's `.opencode/agents` directory:

```bash
PROJECT_DIR=/path/to/your/project
mkdir -pv "$PROJECT_DIR/.opencode/agents"
cp -iv .opencode/agents/* "$PROJECT_DIR/.opencode/agents/"
```

### Global Installation

Create symlinks in your global OpenCode configuration directory:

```bash
mkdir -pv $HOME/.config/opencode/agents
for agent in .opencode/agents/*; do
  ln -si "$(pwd)/$agent" "$HOME/.config/opencode/agents/$(basename $agent)"
done
```

This makes the agents available to all OpenCode projects on your system.

Global installation can be perfomed by running `./scripts/link.sh`

### Updating

To update your globally installed agents with the latest changes:

```bash
cd runway
git pull origin main
./scripts/link.sh
# restart your client
```

The symlinks will automatically reflect any updates made to the agent files in the repository.
