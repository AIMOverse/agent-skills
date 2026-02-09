#!/usr/bin/env bash
# AiMo Network -- Using Services as a Client
#
# Examples of consuming chat models, MCP, and A2A services through the AiMo router.
# Demonstrates the chat model reverse proxy and service discovery.
#
# Prerequisites:
#   - aimo CLI (auto-installs if not found)
#   - A keypair at ~/.config/aimo/keypair.json (run: aimo keygen)
#   - Sufficient session balance or X402 payment capability
#
# Usage:
#   chmod +x use_services.sh
#   ./use_services.sh [agent_id]

set -euo pipefail

KEYPAIR="${AIMO_KEYPAIR:-$HOME/.config/aimo/keypair.json}"
ROUTER_URL="${AIMO_ROUTER_URL:-https://beta.aimo.network}"

# ── Step 0: Install CLI (if not already installed) ───────────────────────────

if ! command -v aimo &> /dev/null; then
    echo "==> AiMo CLI not found, installing..."
    curl -fsSL https://aimo-cli-releases.s3.ap-northeast-1.amazonaws.com/install.sh | sh
    export PATH="$HOME/.aimo/bin:$PATH"
fi

# ── Service Discovery ────────────────────────────────────────────────────────

echo "==> Listing available models:"
aimo router list-models --json --router-url "$ROUTER_URL" | jq -r '.[].id' | head -10

echo ""
echo "==> Searching for GPT models:"
aimo router search-models "gpt" --json --router-url "$ROUTER_URL" | jq -r '.data[].id'

echo ""
echo "==> Listing available tools:"
aimo router list-tools --json --router-url "$ROUTER_URL" | jq -r '.[].name' | head -5

echo ""
echo "==> Listing registered agents:"
aimo router list-agents --json --router-url "$ROUTER_URL" | jq -r '.[].agent_id' | head -5

# ── Chat Model Reverse Proxy ─────────────────────────────────────────────────

echo ""
echo "==> Using chat model reverse proxy with DeepSeek:"
aimo chat \
    --model deepseek/deepseek-v3.2 \
    --message "Explain the AiMo Network in one sentence" \
    --keypair "$KEYPAIR" \
    --router-url "$ROUTER_URL"

echo ""
echo "==> Using chat model reverse proxy with Claude:"
aimo chat \
    --model anthropic/claude-opus-4.6 \
    --message "What are the benefits of decentralized AI infrastructure?" \
    --keypair "$KEYPAIR" \
    --router-url "$ROUTER_URL"

echo ""
echo "==> Chat with system prompt:"
aimo chat \
    --model deepseek/deepseek-v3.2 \
    --system "You are a helpful coding assistant. Keep explanations concise." \
    --message "Explain quicksort in one paragraph" \
    --keypair "$KEYPAIR" \
    --router-url "$ROUTER_URL"

# ── Chat Completions (legacy example) ────────────────────────────────────────

echo ""
echo "==> Sending a chat completion:"
aimo chat \
    --model deepseek/deepseek-v3.2 \
    --message "Explain quicksort in one paragraph" \
    --keypair "$KEYPAIR" \
    --router-url "$ROUTER_URL"

# ── MCP ──────────────────────────────────────────────────────────────────────

# Replace <agent_id> with an actual agent ID from list-agents above.
AGENT_ID="${1:-<agent_id>}"

if [ "$AGENT_ID" != "<agent_id>" ]; then
    echo ""
    echo "==> Initializing MCP session with agent $AGENT_ID:"
    aimo mcp initialize "$AGENT_ID" --keypair "$KEYPAIR" --router-url "$ROUTER_URL"

    echo ""
    echo "==> Listing MCP tools for agent $AGENT_ID:"
    aimo mcp list-tools "$AGENT_ID" --keypair "$KEYPAIR" --router-url "$ROUTER_URL"
else
    echo ""
    echo "==> Skipping MCP/A2A examples (pass an agent_id as first argument)"
    echo "    Usage: ./use_services.sh <agent_id>"
fi

# ── A2A ──────────────────────────────────────────────────────────────────────

if [ "$AGENT_ID" != "<agent_id>" ]; then
    echo ""
    echo "==> Getting A2A agent card for $AGENT_ID:"
    aimo a2a get-card "$AGENT_ID" --json --router-url "$ROUTER_URL"

    echo ""
    echo "==> Sending A2A message to $AGENT_ID:"
    aimo a2a send "$AGENT_ID" "Hello from the AiMo CLI" \
        --keypair "$KEYPAIR" \
        --router-url "$ROUTER_URL"
fi

echo ""
echo "Done."
