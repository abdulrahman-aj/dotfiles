#!/usr/bin/env bash
set -euo pipefail

missing=()

for command_name in stow bash fish curl git nvim python3; do
    if ! command -v "$command_name" >/dev/null 2>&1; then
        missing+=("$command_name")
    fi
done

if ((${#missing[@]})); then
    printf 'Missing requirements:\n' >&2
    printf '  - %s\n' "${missing[@]}" >&2
    exit 1
fi

echo "All deployment requirements are available"
