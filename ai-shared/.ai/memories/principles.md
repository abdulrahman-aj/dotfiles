# Principles

## Software Design
* **Deep modules**: prefer small, stable interfaces hiding rich implementations.
* **Pull complexity down**: keep APIs simple. Push complexity into the implementation.
* **Information hiding**: expose capabilities, not implementation decisions.
* **Simplicity wins**: complexity compounds. Every abstraction must earn its existence.
* **Abstractions**: don't introduce one until it clearly reduces complexity.
* **Readability**: prefer readable code over compactness. Extract non-trivial logic instead of embedding it inline.
* **Flat indentation**: keep nesting ≤3 levels. Extract helpers, early-return, or guard-clause before going deeper.
* **Avoid cleverness**: if the solution requires intricate reasoning, it's probably wrong.
* **Naming**: unclear names signal unclear abstractions. Rethink the design.
* **Locality**: behavior should be understandable from nearby code. Avoid hidden side effects and distant dependencies.
* **DRY**: prefer locality. Duplicate first; abstract when a stable concept emerges.
* **Comments**: explain why, not what. Reserve comments for design rationale, invariants, non-obvious performance decisions, and external constraints.

## Testing
* **Test what you fear**: prioritize code that's most likely to break.
* **Beyoncé rule**: if code took real effort to get right, protect it with a test.
* **Behavior over implementation**: test observable behavior, not internal details.
* **Bug discipline**: every bug fix gets a regression test.

## Refactoring
* **Scout rule**: leave the code cleaner than you found it.
* **Refactor first**: make the change easy, then make the easy change.
* **Defer unrelated work**: stay in scope and record worthwhile refactors in `.refactor-agent.md`.

## Workflow
* **Plan first**: enter plan mode for non-trivial tasks (3+ steps or architectural decisions).
* **Verify**: don't declare success without evidence (tests, logs, or observable behavior).
* **Root cause**: solve the underlying cause, not the symptom.
* **Tracer bullets**: build a thin end-to-end slice before filling in details.
* **Reversible first**: flag hard-to-reverse decisions before making them.

## Collaboration
* **Approval required**: get explicit user approval before Git commits or destructive actions.

## Misc
* **Project tasks first**: check for project tasks (e.g. Makefiles, Taskfiles) before running commands.
