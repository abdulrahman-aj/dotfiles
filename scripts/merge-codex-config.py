#!/usr/bin/env python3
"""Merge codex/config.base.toml with locally-accumulated personal sections.

Codex appends [projects.*], [tui.*], and [notice.*] sections to config.toml
at runtime. This script preserves those sections when regenerating the file
from the tracked base config, so personal paths never enter the dotfiles repo.
"""
import pathlib
import re
import sys

base = pathlib.Path("codex/.codex/config.base.toml").read_text()
target = pathlib.Path(sys.argv[1])

personal = ""
if target.exists():
    lines = target.read_text().splitlines(keepends=True)
    for i, line in enumerate(lines):
        if re.match(r"^\[(projects|tui|notice)\.", line):
            personal = "".join(lines[i:])
            break

target.write_text(base.rstrip() + "\n" + personal)
