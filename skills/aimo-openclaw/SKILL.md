---
name: aimo-openclaw
description: Use AiMo Network as an OpenAI-compatible model provider for OpenClaw. Start the aimo chat local reverse proxy and configure OpenClaw to route requests through it, giving OpenClaw access to hundreds of AI models via a single local endpoint.
license: MIT
compatibility: Requires the aimo CLI (with a valid keypair) and an OpenClaw instance. The aimo CLI is distributed as a pre-built binary with automatic installation via curl.
metadata:
  author: AIMOverse
  version: "0.1.0"
---

# Using AiMo Network as a Model Provider for OpenClaw

This guide explains how to connect [OpenClaw](https://github.com/openclaw/openclaw)
to the AiMo Network so that OpenClaw can use any model available on the network
(DeepSeek, Anthropic, OpenAI, Google, and more) through a single local endpoint.

The setup has two parts:

1. Start the **aimo chat reverse proxy** locally.
2. Point **OpenClaw** at the local proxy as a custom OpenAI-compatible provider.

---

## Prerequisites

- **aimo CLI** installed and a keypair generated (see the `aimo-network` skill).
- A running **OpenClaw** instance.

If you have not installed the CLI yet:

```bash
curl -fsSL https://aimo-cli-releases.s3.ap-northeast-1.amazonaws.com/install.sh | sh
aimo keygen
```

---

## Step 1: Start the AiMo Chat Reverse Proxy

Run the following command to start a local OpenAI-compatible proxy server:

```bash
aimo chat --serve
```

This launches a local HTTP server that proxies requests to the AiMo Network
router. By default the server listens on `http://127.0.0.1:8080` and exposes an
OpenAI-compatible `/v1/chat/completions` endpoint.

You can specify a custom port or keypair:

```bash
aimo chat --serve --port 9090 --keypair ~/.config/aimo/keypair.json
```

Keep this process running in the background (or in a separate terminal / tmux
session) while OpenClaw is active.

### Verify the proxy is running

```bash
curl http://127.0.0.1:8080/v1/models
```

You should see a JSON list of available models from the AiMo Network.

---

## Step 2: Configure OpenClaw to Use the Local Proxy

Open your OpenClaw configuration file (usually `~/.openclaw/openclaw.json`) and
add an `aimo` provider under `models.providers`.

Reference: [OpenClaw Model Providers documentation](https://docs.openclaw.ai/concepts/model-providers#providers-via-models-providers-custom%2Fbase-url)

### Minimal configuration

Add the following to your `openclaw.json`:

```json
{
  "models": {
    "mode": "merge",
    "providers": {
      "aimo": {
        "baseUrl": "http://127.0.0.1:8080/v1",
        "apiKey": "aimo-local",
        "api": "openai-completions"
      }
    }
  }
}
```

- **`baseUrl`** -- points to the local proxy started in Step 1. Change the port
  if you used a custom `--port` flag.
- **`apiKey`** -- can be any non-empty string; authentication is handled by the
  aimo proxy via SIWx signatures, not by an API key.
- **`api`** -- must be `"openai-completions"` so OpenClaw uses the correct
  request format.

### Configuration with explicit model definitions

If you want to define specific models and their metadata:

```json
{
  "models": {
    "mode": "merge",
    "providers": {
      "aimo": {
        "baseUrl": "http://127.0.0.1:8080/v1",
        "apiKey": "aimo-local",
        "api": "openai-completions",
        "models": [
          {
            "id": "deepseek/deepseek-v3.2",
            "name": "DeepSeek V3.2",
            "reasoning": false,
            "input": ["text"],
            "contextWindow": 65536,
            "maxTokens": 8192
          },
          {
            "id": "anthropic/claude-opus-4.6",
            "name": "Claude Opus 4.6",
            "reasoning": true,
            "input": ["text"],
            "contextWindow": 200000,
            "maxTokens": 32000
          }
        ]
      }
    }
  }
}
```

### Set the active model

To make an AiMo model the default in OpenClaw, add it to `agents.defaults`:

```json
{
  "agents": {
    "defaults": {
      "model": {
        "primary": "aimo/deepseek/deepseek-v3.2"
      }
    }
  }
}
```

The format is `<provider-name>/<model-id>`, where provider name matches the key
you used in `models.providers` (in this case `aimo`).

---

## Putting It All Together

1. **Start the proxy** (keep it running):

   ```bash
   aimo chat --serve
   ```

2. **Edit `~/.openclaw/openclaw.json`** to add the `aimo` provider (see above).

3. **Restart OpenClaw** to pick up the new configuration.

4. **Select the model** in OpenClaw using the format `aimo/<model-id>`, for
   example `aimo/deepseek/deepseek-v3.2`.

---

## Discover Available Models

To see which models you can use through the proxy:

```bash
# Via the aimo CLI
aimo router list-models

# Via the local proxy endpoint
curl http://127.0.0.1:8080/v1/models
```

---

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| OpenClaw says "No API provider registered" | Ensure `"api": "openai-completions"` is set in the provider config. |
| Connection refused | Verify `aimo chat --serve` is still running and the port matches `baseUrl`. |
| Model not found | Run `aimo router list-models` to check the exact model ID, then use it in the config. |
| Authentication error from aimo | Run `aimo keygen` if you haven't generated a keypair, or check your `--keypair` path. |
