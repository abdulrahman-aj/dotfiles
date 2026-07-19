# Agent delegation

Minimize expected total cost, including retries and supervision. Delegate isolated work; keep tiny or context-heavy tasks in the primary agent.

## Models

| Agent            | Cost      | Use                                                                                      |
| ---------------- | --------- | ---------------------------------------------------------------------------------------- |
| `minimax-m3`     | Low       | Default for clear, scoped coding within 512k.                                            |
| `deepseek-v4-pro`| Low       | Scoped tasks needing more reasoning or debugging than M3.                                |
| `luna`           | Low       | Fast scanning, extraction, and straightforward large-context work.                       |
| `terra`          | Medium    | Everyday coding, debugging, integration, and repeated tool use.                          |
| `kimi-k3`        | High      | Premium specialist for architecture, ambiguity, synthesis, and visual/frontend judgment. |
| `sol`            | Very high | Hardest or highest-risk reasoning and engineering tasks.                                 |

Cheapest capable model wins.

After one materially improved retry, escalate capability failures:

`minimax-m3` → `terra` → `sol`

Use `kimi-k3` instead when the difficulty is primarily long-context analysis, research, architecture, or synthesis.

## Review

Delegate reviews only when explicitly requested; otherwise review directly.

When needed, use a read-only reviewer from another family:

* OpenAI → `deepseek-v4-pro`
* Moonshot → `deepseek-v4-pro`
* Zhipu → `terra`
* MiniMax → `deepseek-v4-pro`
* DeepSeek → `terra`

Pass the requirements, scope, motivation, and verification results when available—not the implementer’s reasoning. Use a stronger reviewer for high-risk changes or behavior that is hard to verify automatically.
