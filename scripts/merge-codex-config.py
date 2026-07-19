#!/usr/bin/env python3
"""Update repo-managed Codex settings while preserving local settings."""
import os
import pathlib
import stat
import sys
import tempfile
import tomllib

START_MARKER = "# BEGIN dotfiles-managed Codex settings"
END_MARKER = "# END dotfiles-managed Codex settings"

if len(sys.argv) != 3:
    raise SystemExit(f"usage: {sys.argv[0]} MANAGED_CONFIG TARGET")

managed_config_path = pathlib.Path(sys.argv[1])
target = pathlib.Path(sys.argv[2])
managed_config_text = managed_config_path.read_text(encoding="utf-8").rstrip() + "\n"


def parse_toml(text: str, source: pathlib.Path) -> None:
    try:
        tomllib.loads(text)
    except tomllib.TOMLDecodeError as error:
        raise SystemExit(f"Invalid TOML in {source}: {error}") from error


def validate_managed_config() -> None:
    if managed_config_text.count(START_MARKER) != 1 or managed_config_text.count(END_MARKER) != 1:
        raise SystemExit(f"{managed_config_path} must contain exactly one managed marker pair")
    if managed_config_text.index(START_MARKER) >= managed_config_text.index(END_MARKER):
        raise SystemExit(f"Managed markers are reversed in {managed_config_path}")
    parse_toml(managed_config_text, managed_config_path)


def write_target(text: str) -> None:
    target.parent.mkdir(parents=True, exist_ok=True)
    mode = stat.S_IMODE(target.stat().st_mode) if target.exists() else 0o600
    temporary_path: pathlib.Path | None = None

    try:
        with tempfile.NamedTemporaryFile(
            mode="w",
            encoding="utf-8",
            dir=target.parent,
            prefix=f".{target.name}.",
            delete=False,
        ) as temporary:
            temporary.write(text)
            temporary_path = pathlib.Path(temporary.name)

        os.chmod(temporary_path, mode)
        os.replace(temporary_path, target)
        temporary_path = None
    finally:
        if temporary_path is not None:
            temporary_path.unlink(missing_ok=True)


def replace_managed_block(existing_text: str) -> str:
    if existing_text.count(START_MARKER) != 1 or existing_text.count(END_MARKER) != 1:
        raise SystemExit(f"Managed markers are missing or malformed in {target}; refusing to rewrite it")

    start = existing_text.index(START_MARKER)
    end = existing_text.index(END_MARKER)
    if start >= end:
        raise SystemExit(f"Managed markers are reversed in {target}; refusing to rewrite it")

    suffix = end + len(END_MARKER)
    return existing_text[:start] + managed_config_text.rstrip() + existing_text[suffix:]


validate_managed_config()

if not target.exists():
    merged_text = managed_config_text
else:
    existing_text = target.read_text(encoding="utf-8")
    parse_toml(existing_text, target)
    merged_text = replace_managed_block(existing_text)

parse_toml(merged_text, target)
if not target.exists() or target.read_text(encoding="utf-8") != merged_text:
    write_target(merged_text)
