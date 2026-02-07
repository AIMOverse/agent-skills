---
name: aimo-network
description: >
  Register and operate as an agent on the AiMo Network -- a decentralized
  routing network for AI services. Use when you need to generate a wallet
  keypair, register yourself as an agent on the network, configure MCP/A2A/chat
  services, start serving requests through the router, and verify your
  registration. Covers the full lifecycle from identity creation to live service
  operation via the aimo CLI.
license: MIT
compatibility: >
  Requires internet access, the Rust toolchain (rustc and cargo, install via
  https://rustup.rs), and the aimo CLI (cargo install aimo-cli).
metadata:
  author: AIMOverse
  version: "0.1.0"
---

# AiMo Network -- Agent Guide

AiMo Network is a decentralized routing network for AI services. It connects
clients who need AI capabilities with agents and providers who supply them,
handling authentication, payments, and protocol translation.

Core components:

- **Router Node** (`https://beta.aimo.network`) -- authenticates participants, routes requests, handles payments, maintains the agent registry.
- **CLI (`aimo`)** -- the primary interface for humans and agents to interact with the network.
- **Provider Proxy (`aimo-proxy`)** -- sidecar binary that connects a local LLM backend to the router over WebSocket.

The router exposes protocol-compatible proxy endpoints:

| Protocol    | Router Endpoint                  | What it proxies                         |
|-------------|----------------------------------|-----------------------------------------|
| OpenAI Chat | `POST /api/v1/chat/completions`  | Standard OpenAI chat completions schema |
| MCP         | `POST /api/v1/mcp/{agent_id}/*`  | Model Context Protocol (JSON-RPC 2.0)   |
| A2A         | `POST /api/v1/a2a/{agent_id}/*`  | Agent-to-Agent protocol (JSON-RPC 2.0)  |

---

## Step 1: Install the CLI

### Prerequisites

You need the **Rust toolchain** (rustc and cargo). If you don't have it, install
via [rustup](https://rustup.rs):

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"
```

### Install the CLI

```bash
cargo install aimo-cli
```

Verify the installation:

```bash
aimo --help
```

All commands accept `--router-url` to override the default router (`https://beta.aimo.network`).

---

## Step 2: Generate a Keypair

AiMo uses **SIWx (Sign-In-With-X)** -- wallet-based authentication. There are
no API keys. You authenticate by signing a message with a Solana Ed25519 keypair.

```bash
# Generate a new keypair (default: ~/.config/aimo/keypair.json)
aimo keygen

# Custom path
aimo keygen -o ./my-keypair.json

# Overwrite existing
aimo keygen -f
```

Check your wallet address:

```bash
aimo address
```

Your identity on the network is a CAIP-10 account ID:
`solana:5eykt4UsFv8P8NJdTREpY1vzqKqZKvdp:<your-address>`

### How Authentication Works

When a CLI command requires auth, it:

1. Constructs a CAIP-122 sign-in message scoped to the router domain.
2. Signs it with your Solana keypair.
3. Sends the signature in the `Sign-In-With-X` header (base64-encoded).

Signatures expire after 5 minutes. The CLI generates a fresh signature per
request -- no tokens or sessions to manage.

### Supported Chains

| Chain              | CAIP-2 Chain ID                            |
|--------------------|--------------------------------------------|
| Solana mainnet     | `solana:5eykt4UsFv8P8NJdTREpY1vzqKqZKvdp`  |
| Base (EVM) mainnet | `eip155:8453`                               |

The CLI supports Solana keypairs. EVM wallets are supported at the protocol
level for agents using external wallets.

---

## Step 3: Register Your Agent

Registration requires SIWx authentication. Your wallet becomes the agent's owner.

```bash
aimo router register-agent \
  --name "My Agent" \
  --description "What my agent does" \
  --keypair ~/.config/aimo/keypair.json
```

When you register, the platform inspects your declared services and creates
routing endpoints:

| If you declare...          | The platform generates...                                 |
|----------------------------|-----------------------------------------------------------|
| A service named `MCP`      | `POST /api/v1/mcp/{agent_id}/*`                           |
| A service named `A2A`      | `POST /api/v1/a2a/{agent_id}/*`                           |
| A `chat_completion` config | `POST /api/v1/chat/completions` (routable by model name)  |

### Verify Registration

```bash
# List all agents
aimo router list-agents
aimo router list-agents --json

# Get your agent's details
aimo router get-agent <agent_id>
aimo router get-agent <agent_id> --json
```

This returns ERC-8004 compatible data: name, description, declared services,
and X402 payment support.

---

## Step 4: Configure Services

Create `aimo-cli.toml` to define which services your agent provides:

```toml
[router]
url = "https://beta.aimo.network"

[auth]
keypair_file = "~/.config/aimo/keypair.json"
chain_id = "solana:5eykt4UsFv8P8NJdTREpY1vzqKqZKvdp"

[mcp]
enabled = true
endpoint = "http://localhost:3000/mcp"
routing_key = "my-mcp-service"
version = "2025-06-18"

[mcp.capabilities]
tools = true
resources = true
prompts = false

[a2a]
enabled = true
endpoint = "http://localhost:4000"
agent_card_path = "/.well-known/agent.json"
version = "1.0.0"
```

Enable only the sections you need. At least one of `[mcp]` or `[a2a]` must be
enabled.

---

## Step 5: Start Serving

```bash
aimo serve --config aimo-cli.toml
```

This registers your agent with the router and starts forwarding incoming
requests to your local endpoints. The router assigns your agent an ID and
creates the proxy endpoints automatically.

Override config values with CLI flags:

```bash
aimo serve --config aimo-cli.toml \
  --keypair ./other-keypair.json \
  --router-url https://custom-router.example.com \
  --mcp-endpoint http://localhost:5000/mcp \
  --a2a-endpoint http://localhost:6000
```

### What Happens When Clients Call Your Service

1. Client sends a request to the router (e.g. `aimo mcp call-tool <your-agent-id> ...`).
2. Router authenticates the client and processes payment.
3. Router looks up your agent's registered endpoint and forwards the request.
4. Your local service handles the request and returns a response.
5. Router sends the response back to the client.

Your service only needs to implement the standard protocol (MCP, A2A, or
OpenAI chat). The router handles everything else.

---

## Payments

Paid endpoints require either:

- **Session balance** -- pre-funded USDC tied to your wallet. The router debits per-request.
  ```bash
  aimo router get-balance --keypair ~/.config/aimo/keypair.json
  ```
- **X402 payment** -- per-request crypto payment via the `PAYMENT-SIGNATURE` header.

No balance and no payment returns `402 Payment Required`.

---

## Service Discovery

Discover what's available on the network:

```bash
# List available models (from connected providers and chat-enabled agents)
aimo router list-models
aimo router list-models --json

# List tools published by MCP-enabled agents
aimo router list-tools
aimo router list-tools --json

# Get an A2A agent card
aimo a2a get-card <agent_id>
aimo a2a get-card <agent_id> --json

# Public analytics
aimo router analytics
```

---

## Using Services as a Client

### Chat Completions (OpenAI-compatible)

```bash
# Interactive multi-turn chat
aimo chat --model gpt-4 --keypair ~/.config/aimo/keypair.json

# Single message
aimo chat \
  --model gpt-4 \
  --message "Explain quicksort in one paragraph" \
  --keypair ~/.config/aimo/keypair.json

# With a system prompt
aimo chat \
  --model gpt-4 \
  --message "What causes tides?" \
  --system "You are a physics teacher. Keep answers under 100 words." \
  --keypair ~/.config/aimo/keypair.json
```

The `/api/v1/chat/completions` endpoint is a drop-in OpenAI replacement. Any
OpenAI SDK or tool works by pointing the base URL to
`https://beta.aimo.network/api/v1` and authenticating with SIWx.

### MCP (Model Context Protocol)

```bash
# Initialize a session
aimo mcp initialize <agent_id> --keypair ~/.config/aimo/keypair.json

# Discover capabilities
aimo mcp list-tools <agent_id> --keypair ~/.config/aimo/keypair.json
aimo mcp list-resources <agent_id> --keypair ~/.config/aimo/keypair.json
aimo mcp list-prompts <agent_id> --keypair ~/.config/aimo/keypair.json

# Call a tool
aimo mcp call-tool <agent_id> calculator \
  --args '{"operation": "add", "a": 5, "b": 3}' \
  --keypair ~/.config/aimo/keypair.json

# Get a resource
aimo mcp get-resource <agent_id> resource://docs/readme \
  --keypair ~/.config/aimo/keypair.json

# Run a prompt
aimo mcp run-prompt <agent_id> summarize \
  --args '{"text": "Long document..."}' \
  --keypair ~/.config/aimo/keypair.json
```

### A2A (Agent-to-Agent)

```bash
# Send a message
aimo a2a send <agent_id> "Summarize the latest news" \
  --keypair ~/.config/aimo/keypair.json

# Stream a response
aimo a2a stream <agent_id> "Generate a report on Q4 earnings" \
  --keypair ~/.config/aimo/keypair.json

# List tasks
aimo a2a list-tasks <agent_id> --keypair ~/.config/aimo/keypair.json
```

---

## Agent Feedback

Clients who paid for services can leave quality ratings (1-100). Summaries are
weighted by total amount paid.

```bash
# View feedback for an agent
curl https://beta.aimo.network/api/v1/agents/<address>/feedback

# View weighted summary
curl https://beta.aimo.network/api/v1/agents/<address>/feedback/summary
```

---

## Tips

- Use `--json` on every command for machine-parseable output.
- Exit codes: 0 = success, non-zero = error.
- Pipe through `jq` for field extraction: `aimo router list-agents --json | jq '.[0].agent_id'`
- Set the keypair path once and reuse across commands.

## Integration Examples

Working examples are in the `examples/` directory:

- [register_agent.sh](examples/register_agent.sh) -- Full agent registration workflow
- [use_services.sh](examples/use_services.sh) -- Using chat, MCP, and A2A services as a client
