#!/usr/bin/env bash
set -euo pipefail

target="${1:-$HOME}"
target="$(realpath -m "$target")"
export HOME="$target"
export XDG_CONFIG_HOME="$target/.config"

mkdir -p "$XDG_CONFIG_HOME/fish"

if ! fish -c 'type -q fisher'; then
    installer="$(mktemp)"
    trap 'rm -f "$installer"' EXIT
    curl --fail --show-error --silent --location \
        --output "$installer" \
        https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish
    fish -c 'source "$argv[1]"; fisher update' \
        "$installer"
else
    fish -c 'fisher update'
fi
