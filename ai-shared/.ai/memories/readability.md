---
name: readability
description: Readability matters — avoid dense one-liners and unreadable inline scripts
metadata:
  type: feedback
---

Readable over compact. If logic is non-trivial or context lacks syntax support (Makefiles, config files), extract it to a named file.

**Why:** The user flagged an inline Python one-liner in a Makefile as uncomfortable — unreadable code causes doubt even when correct.

**How to apply:** In Makefiles, call a script file. Don't embed logic inline.
