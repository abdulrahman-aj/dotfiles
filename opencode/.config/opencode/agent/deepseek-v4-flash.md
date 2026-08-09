---
description: Low-cost alternative for routine, high-volume, or straightforward tasks.
mode: subagent
model: opencode-go/deepseek-v4-flash
reasoningEffort: high
permission:
  task: deny
---

Complete the delegated task directly and return a concise result. Stay within scope, preserve unrelated changes, and verify work when practical.

When the free tier quota is available, set `model:` to `opencode/deepseek-v4-flash-free` (context limited to 200k). Flip back to `opencode-go/deepseek-v4-flash` when the quota runs out.
