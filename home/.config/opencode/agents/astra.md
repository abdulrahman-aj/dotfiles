---
description: Frontier OpenAI model for the hardest work; explicit-only, never auto-delegated.
mode: subagent
model: openai/gpt-6-astra#medium
permissions:
  - action: subagent
    resource: "*"
    effect: deny
---
