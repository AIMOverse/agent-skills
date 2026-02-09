#!/usr/bin/env bash
# AiMo Network -- Agent Registration Workflow
#
# This script walks through the full lifecycle of registering an agent on the
# AiMo Network: CLI installation, keypair generation, agent registration,
# service configuration, and starting the proxy.
#
# Prerequisites:
#   - curl (for CLI installation)
#
# Usage:
#   chmod +x register_agent.sh
#   ./register_agent.sh

set -euo pipefail

ROUTER_URL="${AIMO_ROUTER_URL:-https://beta.aimo.network}"
KEYPAIR="${AIMO_KEYPAIR:-$HOME/.config/aimo/keypair.json}"

# ── Step 0: Install CLI (if not already installed) ───────────────────────────

if ! command -v aimo &> /dev/null; then
    echo "==> AiMo CLI not found, installing..."
    curl -fsSL https://aimo-cli-releases.s3.ap-northeast-1.amazonaws.com/install.sh | sh
    
    # Reload PATH
    export PATH="$HOME/.aimo/bin:$PATH"
else
    echo "==> AiMo CLI already installed"
fi

aimo --version

# ── Step 1: Generate a keypair ───────────────────────────────────────────────

echo "==> Generating keypair at $KEYPAIR"
if [ -f "$KEYPAIR" ]; then
    echo "    Keypair already exists, skipping (use aimo keygen -f to overwrite)"
else
    aimo keygen -o "$KEYPAIR"
fi

echo "==> Your wallet address:"
aimo address

# ── Step 2: Register the agent ───────────────────────────────────────────────

AGENT_NAME="${1:-My Agent}"
AGENT_DESC="${2:-An AI agent registered on AiMo Network}"

echo "==> Registering agent: $AGENT_NAME"
aimo router register-agent \
    --name "$AGENT_NAME" \
    --description "$AGENT_DESC" \
    --keypair "$KEYPAIR" \
    --router-url "$ROUTER_URL"

# ── Step 3: Verify registration ─────────────────────────────────────────────

echo "==> Listing agents to verify registration:"
aimo router list-agents --json --router-url "$ROUTER_URL" | jq '.[] | select(.name == "'"$AGENT_NAME"'")'

# ── Step 4: Write a service configuration ────────────────────────────────────

CONFIG_FILE="aimo-cli.toml"

echo "==> Writing service configuration to $CONFIG_FILE"
cat > "$CONFIG_FILE" <<TOML
[router]
url = "$ROUTER_URL"

[auth]
keypair_file = "$KEYPAIR"
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
TOML

echo "==> Configuration written. Review it:"
cat "$CONFIG_FILE"

# ── Step 5: Start the proxy ─────────────────────────────────────────────────

echo ""
echo "==> To start serving, run:"
echo "    aimo serve --config $CONFIG_FILE"
echo ""
echo "==> To check your balance:"
echo "    aimo router get-balance --keypair $KEYPAIR"
echo ""
echo "Done."
