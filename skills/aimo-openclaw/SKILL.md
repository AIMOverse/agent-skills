---
name: aimo-openclaw
description: Switch OpenClaw to use AiMo Network for LLM inference. Teaches the agent how to start the aimo chat reverse proxy and reconfigure its own OpenClaw instance to route all model requests through AiMo Network.
license: MIT
compatibility: Requires the aimo CLI (with a valid keypair) and a running OpenClaw instance. The aimo CLI is distributed as a pre-built binary with automatic installation via curl.
metadata:
  author: AIMOverse
  version: "0.1.0"
---

# Switch OpenClaw to AiMo Network for LLM Inference

You are an OpenClaw agent. Follow these instructions to switch your LLM backend
to AiMo Network, giving you access to hundreds of models (DeepSeek, Anthropic,
OpenAI, Google, and more) through a single local proxy.

---

## 1. Install the aimo CLI (if not already installed)

Check whether the CLI is available:

```bash
aimo --version
```

If the command is not found, install it:

```bash
curl -fsSL https://aimo-cli-releases.s3.ap-northeast-1.amazonaws.com/install.sh | sh
```

## 2. Generate a keypair (if none exists)

Check for an existing keypair:

```bash
ls ~/.config/aimo/keypair.json
```

If the file does not exist, generate one:

```bash
aimo keygen
```

## 3. Start the local reverse proxy

Run:

```bash
aimo chat --serve
```

This starts an OpenAI-compatible proxy at `http://127.0.0.1:8080/v1`. It must
stay running while OpenClaw uses it. Start it in the background or in a separate
terminal/tmux session.

To use a different port:

```bash
aimo chat --serve --port <port>
```

Verify it is running:

```bash
curl -s http://127.0.0.1:8080/v1/models
```

This should return a JSON array of available models. If it does not, the proxy is
not running. Go back and start it.

## 4. Configure OpenClaw to use the proxy

The OpenClaw config file is at `~/.openclaw/openclaw.json`.

Read the current config, then **merge** the following into it (do not overwrite
unrelated settings):

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

Field explanation:

| Field     | Value                              | Why                                                                 |
|-----------|------------------------------------|---------------------------------------------------------------------|
| `baseUrl` | `http://127.0.0.1:<port>/v1`      | Points to the local proxy from step 3. Match the port you used.     |
| `apiKey`  | Any non-empty string               | Auth is handled by the proxy via SIWx signatures, not by API key.   |
| `api`     | `"openai-completions"`             | Required. Tells OpenClaw to use the OpenAI completions format.      |

Reference: [OpenClaw Model Providers — Custom Base URL](https://docs.openclaw.ai/concepts/model-providers#providers-via-models-providers-custom%2Fbase-url)

### Optional: define explicit models

If you want to pin specific models with metadata, add a `models` array:

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

To discover available model IDs, run:

```bash
aimo router list-models --json
```

### Optional: set an AiMo model as the default

Merge into the same `openclaw.json`:

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

The format is `aimo/<model-id>`, where `aimo` matches the provider key above.

## 5. Verify the configuration

After editing the config, restart OpenClaw to load the changes.

Then confirm the provider is registered by selecting a model with the `aimo/`
prefix (e.g. `aimo/deepseek/deepseek-v3.2`) and sending a test message.

---

## Troubleshooting

| Symptom                                | Action                                                                                      |
|----------------------------------------|---------------------------------------------------------------------------------------------|
| `"No API provider registered"`         | Ensure `"api": "openai-completions"` is present in the provider config.                     |
| Connection refused                     | Run `curl http://127.0.0.1:8080/v1/models` to check the proxy. Restart `aimo chat --serve`. |
| Model not found                        | Run `aimo router list-models` and use the exact model ID in the config.                     |
| Authentication error from aimo proxy   | Run `aimo keygen` to create a keypair, or pass `--keypair <path>` to `aimo chat --serve`.   |
| Config changes not taking effect       | Restart OpenClaw after editing `~/.openclaw/openclaw.json`.                                 |
