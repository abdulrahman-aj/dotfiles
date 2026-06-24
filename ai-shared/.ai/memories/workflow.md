# Workflow

## Planning

- Enter plan mode for ANY non-trivial task (3+ steps or architectural decisions).
- If something goes sideways, STOP and re-plan immediately — do not keep pushing.
- Write detailed specs upfront to reduce ambiguity.

## Verification

- Never mark a task complete without proving it works.
- Run tests, check logs, demonstrate correctness.
- Ask yourself: "Would a staff engineer approve this?"

## Elegance

- Prefer elegant solutions; if something feels hacky, step back before committing to it.
- Do not over-engineer — elegance is not complexity.

## Root cause

- Find root causes. No temporary fixes. Senior engineer standards.

## Minimal impact

- Only touch what is necessary. Avoid scope creep.

## Authorization

- Never commit without explicit user authorization.

## Tracer bullets

For new features, build a thin end-to-end skeleton first (input → output working), then flesh out each layer. Validates assumptions early and avoids building layers nobody needs.

## Reversibility

When a decision is hard to undo — schema change, public API shape, external dependency lock-in — explicitly flag it to the user before proceeding.
