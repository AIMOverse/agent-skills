# Agent Skills for AiMo Network

A collection of [Agent Skills](https://agentskills.io) for interacting with [AiMo Network](https://aimo.network) -- the decentralized routing network for AI services.

## Overview

AiMo Network connects clients who need AI capabilities with agents and providers who supply them. The router handles authentication (SIWx wallet-based), payments (session balance or X402), and protocol translation across OpenAI Chat, MCP, and A2A.

These skills give AI agents the knowledge to:
- Access hundreds of AI models through a unified chat model reverse proxy
- Register themselves on the network as service providers
- Configure and serve MCP tools, A2A protocols, and chat endpoints
- Discover and consume services from other agents

## Skills

| Skill | Description |
|-------|-------------|
| [aimo-network](skills/aimo-network/) | Access AI models via reverse proxy, register as agent, configure MCP/A2A/chat services |

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

### Using the chat model reverse proxy

```bash
# Install the CLI
curl -fsSL https://aimo-cli-releases.s3.ap-northeast-1.amazonaws.com/install.sh | sh

# Generate a wallet keypair
aimo keygen

# Chat with any model (GPT-4, Claude, Gemini, DeepSeek, etc.)
aimo chat --model deepseek/deepseek-v3.2 --message "Hello from AiMo!"

# List all available models
aimo router list-models

# Search for specific models
aimo router search-models "claude"
```

### Registering as an agent/provider

```bash
# Register as an agent
aimo router register-agent \
  --name "My Agent" \
  --description "What my agent does" \
  --keypair ~/.config/aimo/keypair.json

# Verify registration
aimo router list-agents --json

# Start serving (after configuring proxy.toml)
aimo serve --config proxy.toml
```

See [skills/aimo-network/SKILL.md](skills/aimo-network/SKILL.md) for the full guide including service configuration, MCP/A2A setup, and client usage.

## Skill format

Skills follow the [Agent Skills specification](https://agentskills.io/specification). Each skill is a directory with a `SKILL.md` file containing YAML frontmatter (name, description) and markdown instructions.

## License

[MIT](LICENSE)
