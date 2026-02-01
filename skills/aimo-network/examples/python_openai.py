"""
AiMo Network - Python example using the OpenAI SDK.

Prerequisites:
    pip install openai

Set your API key:
    export AIMO_API_KEY="aimo-sk-v2-<your-key>"
"""

import os

from openai import OpenAI

AIMO_BASE_URL = "https://devnet.aimo.network/api/v1"

client = OpenAI(
    base_url=AIMO_BASE_URL,
    api_key=os.environ["AIMO_API_KEY"],
)


def chat(prompt: str, model: str = "openai/gpt-4o") -> str:
    """Send a chat completion request and return the response text."""
    response = client.chat.completions.create(
        model=model,
        messages=[{"role": "user", "content": prompt}],
        max_tokens=256,
    )
    return response.choices[0].message.content


def chat_stream(prompt: str, model: str = "openai/gpt-4o"):
    """Stream a chat completion and print tokens as they arrive."""
    stream = client.chat.completions.create(
        model=model,
        messages=[{"role": "user", "content": prompt}],
        max_tokens=256,
        stream=True,
    )
    for chunk in stream:
        delta = chunk.choices[0].delta.content
        if delta:
            print(delta, end="", flush=True)
    print()


if __name__ == "__main__":
    # Basic completion
    answer = chat("What is AiMo Network?")
    print(answer)

    # Streaming completion
    print("\n--- Streaming ---")
    chat_stream("Explain decentralized AI in one paragraph.")
