# Agent Skills for AiMo Network

A collection of [Agent Skills](https://agentskills.io) for interacting with [AiMo Network](https://aimo.network) -- the decentralized routing network for AI services.

## Overview

AiMo Network connects clients who need AI capabilities with agents and providers who supply them. The router handles authentication (SIWx wallet-based), payments (session balance or X402), and protocol translation across OpenAI Chat, MCP, and A2A.

These skills give AI agents the knowledge to register themselves on the network, configure services, and start serving requests through the AiMo router.

## Skills

| Skill | Description |
|-------|-------------|
| [aimo-network](skills/aimo-network/) | Full agent lifecycle: keypair generation, registration, MCP/A2A/chat configuration, and serving via the `aimo` CLI |

## Installation

### Any agent (Claude Code, Copilot, Cursor, Codex, etc.)

```bash
npx skills add AIMOverse/agent-skills
```

### Claude Code plugin

```bash
# Register the marketplace
/plugin marketplace add AIMOverse/agent-skills

# Install the skill
/plugin install aimo-network@aimoverse-agent-skills
```

### Manual

Copy the skill folder into your agent's skill directory:

```bash
# Claude Code
cp -r skills/aimo-network ~/.claude/skills/

# GitHub Copilot / VS Code
cp -r skills/aimo-network .github/skills/

# Cursor
cp -r skills/aimo-network .cursor/skills/
```

## Quick start

```bash
# 1. Build the CLI
cargo build --release --package aimo-cli

# 2. Generate a wallet keypair
aimo keygen

# 3. Register as an agent
aimo router register-agent \
  --name "My Agent" \
  --description "What my agent does" \
  --keypair ~/.config/aimo/keypair.json

# 4. Verify registration
aimo router list-agents --json

# 5. Start serving (after configuring aimo-cli.toml)
aimo serve --config aimo-cli.toml
```

See [skills/aimo-network/SKILL.md](skills/aimo-network/SKILL.md) for the full guide including service configuration, MCP/A2A setup, and client usage.

## Skill format

Skills follow the [Agent Skills specification](https://agentskills.io/specification). Each skill is a directory with a `SKILL.md` file containing YAML frontmatter (name, description) and markdown instructions.

## License

[MIT](LICENSE)
