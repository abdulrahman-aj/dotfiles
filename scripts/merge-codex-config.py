#!/usr/bin/env python3
"""Merge config.base.toml with the live config, preserving personal sections."""
import pathlib
import re
import sys
import tomllib

base_path = pathlib.Path("codex/.codex/config.base.toml")
target = pathlib.Path(sys.argv[1])

base_text = base_path.read_text()

if not target.exists():
    target.write_text(base_text)
    sys.exit()

existing_text = target.read_text()

base_keys = set(tomllib.loads(base_text).keys())
personal_keys = set(tomllib.loads(existing_text).keys()) - base_keys

personal_text = ""
if personal_keys:
    pattern = r"^\[+(?:" + "|".join(re.escape(k) for k in personal_keys) + r")\."
    match = re.search(pattern, existing_text, re.MULTILINE)
    if match:
        personal_text = existing_text[match.start():]

target.write_text(base_text.rstrip() + "\n" + ("\n" + personal_text if personal_text else ""))
