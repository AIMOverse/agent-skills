/**
 * AiMo Network - TypeScript example using the OpenAI SDK.
 *
 * Prerequisites:
 *   npm install openai
 *
 * Set your API key:
 *   export AIMO_API_KEY="aimo-sk-v2-<your-key>"
 *
 * Run:
 *   npx tsx examples/typescript_openai.ts
 */

import OpenAI from "openai";

const AIMO_BASE_URL = "https://devnet.aimo.network/api/v1";

const client = new OpenAI({
  baseURL: AIMO_BASE_URL,
  apiKey: process.env.AIMO_API_KEY,
});

async function chat(
  prompt: string,
  model: string = "openai/gpt-4o"
): Promise<string> {
  const response = await client.chat.completions.create({
    model,
    messages: [{ role: "user", content: prompt }],
    max_tokens: 256,
  });
  return response.choices[0].message.content ?? "";
}

async function chatStream(
  prompt: string,
  model: string = "openai/gpt-4o"
): Promise<void> {
  const stream = await client.chat.completions.create({
    model,
    messages: [{ role: "user", content: prompt }],
    max_tokens: 256,
    stream: true,
  });
  for await (const chunk of stream) {
    const delta = chunk.choices[0].delta.content;
    if (delta) {
      process.stdout.write(delta);
    }
  }
  console.log();
}

async function main() {
  // Basic completion
  const answer = await chat("What is AiMo Network?");
  console.log(answer);

  // Streaming completion
  console.log("\n--- Streaming ---");
  await chatStream("Explain decentralized AI in one paragraph.");
}

main();
