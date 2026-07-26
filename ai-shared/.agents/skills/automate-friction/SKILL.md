---
name: automate-friction
description: Reduce recurring workflow or environment friction and context pollution.
---

- Review recent work for repeated commands, noisy output, and manual steps.
- Name observed friction; label speculative opportunities.
- Inspect existing Makefiles, task runners, and scripts before adding anything.
- Consider a Nix development environment when setup causes friction.
- Automate commands:
  - Repeated command sequence → script exposed through the Makefile.
  - Long one-line command → simple Makefile target.
  - Prefer the existing script directory; otherwise use `scripts/`.
- Reduce context pollution:
  - Keep successful output concise and failure diagnostics complete.
  - Add `VERBOSE=1` when full output is useful.
  - Consider Make targets for smaller test scopes.
- Consider `make help`.
- Put recurring conventions and constraints in `AGENTS.md`.
- Report concisely.
