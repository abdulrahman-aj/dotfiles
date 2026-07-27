# Agent delegation

Minimize expected total cost, including retries and supervision. Delegate isolated work; keep tiny or context-heavy tasks in the primary agent.

## Models

| Agent             | Cost      |
| ----------------- | --------- |
| `minimax-m3`      | Low       |
| `deepseek-v4-pro` | Low       |
| `luna`            | Low       |
| `terra`           | Medium    |
| `kimi-k3`         | High      |
| `sol`             | Very high |

Cheapest capable model wins. Escalate only when necessary, to the cheapest suitable stronger agent.

## Review

Delegate reviews only when explicitly requested; otherwise review directly.

Choose a cross-family reviewer:

* OpenAI-authored: `deepseek-v4-pro`; stronger: `kimi-k3`.
* Other: `terra`; stronger: `sol`.

Use stronger reviewers only for hard or high-risk work: architectural, security/privacy-sensitive, irreversible, or hard-to-verify changes.

Keep reviews read-only. The `ask-for-review` skill owns briefing and delegation details.
