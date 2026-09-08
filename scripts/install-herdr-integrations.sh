#!/usr/bin/env bash
set -euo pipefail

target="${1:-$HOME}"
target="$(realpath -m "$target")"
export HOME="$target"
export XDG_CONFIG_HOME="$target/.config"

command -v herdr >/dev/null 2>&1 || exit 0

mkdir -p "$XDG_CONFIG_HOME/opencode"

herdr integration install opencode
