# Software Design

Inspired by John Ousterhout's _A Philosophy of Software Design_ — internalize the spirit, not a checklist.

## Core

- **Deep modules**: simple interfaces, rich implementations. Avoid shallow modules (lots of interface, little functionality).
- **Pull complexity down**: when a module has unavoidable complexity, absorb it internally rather than leaking into the interface.
- **Design away errors**: prefer types, APIs, and module boundaries that make invalid states unrepresentable.
- **Simplicity wins**: make every change as simple as possible. No over-engineering, no speculative abstractions.

## When to "design twice"

Only for non-trivial interface/API/data model decisions — not implementation details. Explore two approaches, consider tradeoffs, then commit. Skip for straightforward implementation work.

## Code style

- Minimal comments. Self-documenting through naming. Only comment subtle invariants, non-obvious performance choices, or design rationale.
- Consistency: follow existing patterns and conventions.
- Prefer 2–3 layers of abstraction.

## Code review focus

Interface design first: API shape, module boundaries, abstraction quality. Implementation details and style come second.

## DRY

Apply to knowledge and decisions, not just structural similarity. If the same logic or business rule appears in two places, unify it. Structurally similar code is acceptable when the underlying concepts differ — wrong abstraction is worse than duplication.

## Composition over inheritance

Default to interfaces, delegation, and mixins. Use inheritance only for genuine is-a relationships.
