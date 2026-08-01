# Principles

## Software Design
* **Deep modules**: small, stable interfaces hiding rich implementations. Push complexity down; expose capabilities, not decisions.
* **Simplicity wins**: complexity compounds. Prefer the simplest correct solution; reconsider anything clever, brittle, or surprising.
* **Abstractions**: don't introduce one until it clearly reduces complexity. Duplicate first; abstract when a stable concept emerges.
* **Readability**: prefer readable code over compactness. Extract non-trivial logic instead of embedding it inline.
* **Naming**: unclear names signal unclear abstractions. Rethink the design.
* **Locality**: behavior should be understandable from nearby code. Avoid hidden side effects and distant dependencies.
* **Comments**: explain why, not what. Reserve comments for design rationale, invariants, non-obvious performance decisions, and external constraints.

## Code Style
* **Nesting**: keep nesting to three levels or fewer; extract or return early.
* **Line length**: prefer lines under 100 characters.
* **Scripts**: prefer standalone files over long shell or Python strings.

## Testing
* **Test what you fear**: prioritize code most likely to break or that took real effort to get right.
* **Behavior over implementation**: test observable behavior, not internal details.
* **Avoid brittle tests**: prefer assertions that survive refactoring.
* **Bug discipline**: every bug fix gets a regression test.
* **Test dependencies**: install missing verification tools. Prefer a temporary `nix shell`; downloads are allowed.

## Refactoring
* **Scout rule**: leave the code cleaner than you found it.
* **Chesterton's fence**: before removing an existing constraint, understand why it exists.
* **Refactor first**: make the change easy, then make the easy change.
* **Defer unrelated work**: stay in scope and record worthwhile refactors in `.refactor-agent.md`.

## Workflow
* **Plan first**: enter plan mode for non-trivial tasks (3+ steps or architectural decisions).
* **Verify**: don't declare success without evidence (tests, logs, or observable behavior).
* **Root cause**: solve the underlying cause, not the symptom.
* **Tracer bullets**: build a thin end-to-end slice before filling in details.
* **Reversible first**: flag hard-to-reverse decisions before making them.
* **Port omissions**: explicitly document every omitted upstream behavior in the target repository.
* **Reuse context**: continue with the same sub-agent unless independence or changed scope requires a new one.
* **Agent edits**: use worktrees; primary checkouts only for planning, integration, and post-integration validation (`worktree -h`).
* **Worktree cleanup**: remove managed worktrees from the primary checkout after integration or abandonment.

## Automation
* **Automate friction**: turn recurring manual work and preventable failures into project-local guardrails.
* **Evidence first**: automate observed friction, not hypothetical problems. Ask before adding dependencies or changing shared workflows.
* **Recurring commands**: expose two or more through the existing task runner or a small Makefile.

## Collaboration
* **Approval required**: get explicit user approval before Git commits or destructive actions.

## Misc
* **Project tasks first**: check for project tasks (e.g. Makefiles, Taskfiles) before running commands.
