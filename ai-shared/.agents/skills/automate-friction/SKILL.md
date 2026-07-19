---
name: automate-friction
description: Turn observed failures, repeated manual work, and environment problems into small verified project guardrails. Use when friction appears during a task or when asked to improve automation or reproducibility.
---

# Automate Friction

If no concrete friction was observed, do nothing and say nothing about automation.

## Steps

1. Name the friction.
2. Check the relevant project tasks, checks, and setup. Reuse an existing mechanism when possible.
3. Pick the closest guardrail:
   - Defect or review correction → lint, static analysis, type, or schema rule.
   - Manual behavior check → focused automated test.
   - Repeated commands → existing task runner, or a small Makefile for 2+ commands; scripts hold multi-step internals.
   - Environment mismatch → update the existing setup; otherwise ask to add a Nix shell with only required tools.
   - Domain intent → project guidance only when code or checks cannot enforce it.
   - Agent ergonomics → reduce repeated tool calls, noisy output, or rediscovery with small repo-local improvements; do not hide failures.
4. Implement it now if it is small, in scope, and uses existing tools.
5. Ask first if it needs a new dependency, development environment, or shared workflow change.
6. If it reveals unrelated problems, stop and ask using the Approval output. Do not hide or weaken the check.
7. Make failures explain the fix. Verify a bad case fails, the intended case passes, and the canonical check passes.

## Output

- Success: `Automated: <friction> → <guardrail>. Verified: <bad case rejected>; <canonical check> passes.`
- Approval: `Automation opportunity: <friction> → <guardrail>. Impact: <dependency or workflow change>. Add it?`
