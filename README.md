# Agent Skills for AiMo Network

A collection of [Agent Skills](https://agentskills.io) for interacting with [AiMo Network](https://aimo.network) -- the decentralized AI marketplace.

## Overview

AiMo Network provides permissionless access to hundreds of AI models through a single OpenAI-compatible API with blockchain-based pay-per-use payments (X402 protocol on Solana/Base).

These skills allow AI agents (Claude, GPT, LangChain agents, etc.) to integrate with AiMo Network services.

## Skills

| Skill | Description |
|-------|-------------|
| [aimo-network](skills/aimo-network/) | Chat completions, streaming, X402 payments, and provider routing via AiMo's unified API |

## Quick start

### Python

```bash
pip install openai
export AIMO_API_KEY="aimo-sk-v2-<your-key>"
python skills/aimo-network/examples/python_openai.py
```

### TypeScript

```bash
npm install openai
export AIMO_API_KEY="aimo-sk-v2-<your-key>"
npx tsx skills/aimo-network/examples/typescript_openai.ts
```

## Skill format

Skills follow the [Agent Skills specification](https://agentskills.io/specification). Each skill is a directory with a `SKILL.md` file containing YAML frontmatter (name, description) and markdown instructions.

## License

[MIT](LICENSE)
