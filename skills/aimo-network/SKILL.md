---
name: aimo-network
description: >
  Access the AiMo Network decentralized AI marketplace API. Use when the user
  needs to call AI models through AiMo's OpenAI-compatible endpoint, make
  permissionless X402 crypto payments for inference, or interact with AiMo
  Network services. Supports chat completions, streaming, multi-modal inputs,
  and provider routing across hundreds of models.
license: MIT
compatibility: Requires internet access. Python examples need openai package. TypeScript examples need openai npm package.
metadata:
  author: AIMOverse
  version: "0.1.0"
---

# AiMo Network

AiMo Network is a decentralized AI marketplace providing permissionless access
to hundreds of AI models through a single OpenAI-compatible API with
blockchain-based pay-per-use payments.

## API Endpoints

| Mode | Endpoint | Auth |
|------|----------|------|
| API Key | `https://devnet.aimo.network/api/v1/chat/completions` | `Authorization: Bearer aimo-sk-v2-<key>` |
| X402 (permissionless) | `https://devnet.aimo.network/api/alpha/chat/completions` | None (pays per-request with USDC on Solana/Base) |

## Chat Completions (API Key)

Send a standard OpenAI-compatible chat completion request:

```bash
curl -X POST "https://devnet.aimo.network/api/v1/chat/completions" \
  -H "Authorization: Bearer aimo-sk-v2-<your-api-key>" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "openai/gpt-4o",
    "messages": [{"role": "user", "content": "Hello!"}],
    "max_tokens": 256
  }'
```

## X402 Permissionless Payments

The X402 endpoint requires no API key. Payment is settled on-chain (USDC on
Solana or Base) per request. The model format is `provider_pubkey:model_name`.

Supported parameters: `model` (required), `messages` (required), `stream`,
`max_tokens`, `temperature`, `top_p`.

## Provider Routing

AiMo load-balances requests across providers. Default priority is price.
To prioritize throughput instead, set the `sort` field to `throughput` in
your request body.

## Integration Examples

Working examples are available in the `examples/` directory:

- [Python (OpenAI SDK)](examples/python_openai.py) -- Chat completions via the OpenAI Python package
- [TypeScript (OpenAI SDK)](examples/typescript_openai.ts) -- Chat completions via the OpenAI Node package

## Key Notes

- The API is OpenAI-compatible. Any OpenAI SDK works by overriding `base_url`.
- API keys follow the format `aimo-sk-v2-<key>`.
- Models are namespaced: `provider/model-name` (e.g., `openai/gpt-4o`, `anthropic/claude-sonnet-4-20250514`).
- Streaming is supported via `"stream": true`.
- Multi-modal inputs (images) are supported on compatible models.
