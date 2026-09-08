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
* **Nesting**: reduce nesting for readability, not arbitrary limits.
* **Line length**: prefer lines under 100 characters.
* **Scripts**: prefer standalone files over long shell or Python strings.

## Testing
* **Test what you fear**: prioritize code most likely to break or that took real effort to get right.
* **Behavior over implementation**: test observable behavior, not internal details.
* **Avoid brittle tests**: prefer assertions that survive refactoring.
* **Bug discipline**: add a regression test for fixes; use direct checks when automation is impractical.
* **Test dependencies**: install missing verification tools. Prefer a temporary `nix shell`; downloads are allowed.

## Refactoring
* **Scout rule**: leave touched code cleaner; keep cleanup within the task's scope.
* **Chesterton's fence**: before removing an existing constraint, understand why it exists.
* **Refactoring**: refactor to simplify or safeguard the requested change.

## Workflow
* **Isolation first**: implement in a worktree (`worktree -h`); merge only after checks pass.
* **Planning**: use task lists when they help.
* **Verify**: don't declare success without evidence (tests, logs, or observable behavior).
* **Root cause**: solve the underlying cause, not the symptom.
* **Tracer bullets**: build a thin end-to-end slice before filling in details.
* **Reversible first**: flag hard-to-reverse decisions before making them.
* **Port omissions**: explicitly document every omitted upstream behavior in the target repository.
* **Reuse context**: continue with the same sub-agent unless independence or changed scope requires a new one.
* **Delegation**: use cheaper suitable workers for routine tasks, including verification; keep key decisions and synthesis with the primary. Keep trivial work local.

## Automation
* **Automate friction**: turn recurring manual work and preventable failures into project-local guardrails.
* **Evidence first**: automate observed friction, not hypothetical problems. Ask before adding dependencies or changing shared workflows.
* **Recurring commands**: use the existing task runner for frequently repeated commands.

## Collaboration
* **Approval required**: get explicit user approval before Git commits or destructive actions.

## Misc
* **Project tasks first**: check for project tasks (e.g. Makefiles, Taskfiles) before running commands.
