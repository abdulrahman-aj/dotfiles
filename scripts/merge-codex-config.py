#!/usr/bin/env python3
"""Merge config.base.toml with Codex-managed personal sections from the live config."""

import pathlib
import re
import sys
import tomllib

PERSONAL_SECTIONS = ("projects", "tui", "notice")

BASE = pathlib.Path("codex/.codex/config.base.toml")
TARGET = pathlib.Path(sys.argv[1])


def toml_key(k: str) -> str:
    return k if re.match(r"^[A-Za-z0-9_-]+$", k) else f'"{k}"'


def toml_value(v) -> str:
    return f'"{v}"' if isinstance(v, str) else str(v)


def format_personal(data: dict) -> str:
    parts = []
    for section in PERSONAL_SECTIONS:
        if section not in data:
            continue
        for subsection, values in data[section].items():
            parts.append(f"\n[{section}.{toml_key(subsection)}]")
            for k, v in values.items():
                parts.append(f"{toml_key(k)} = {toml_value(v)}")
    return "\n".join(parts)


personal = ""
if TARGET.exists():
    existing = tomllib.loads(TARGET.read_text())
    personal = format_personal(existing)

content = BASE.read_text().rstrip() + "\n"
if personal:
    content += personal + "\n"
TARGET.write_text(content)
