#!/usr/bin/env bash
set -euo pipefail

target="$(realpath -m "${1:-$HOME}")"
[[ "$target" == "$(realpath -m "$HOME")" ]] || exit 0

bash "$(dirname "${BASH_SOURCE[0]}")/enable-user-units.sh" "$target"

if command -v dms >/dev/null; then
    dms restart || echo 'Dux Shell restart failed; a reboot will apply the settings.' >&2
fi

[[ -t 0 ]] || exit 0
read -r -p 'Reboot now to apply login-shell and system changes? [y/N] ' reply || exit 0
case "$reply" in
    [Yy]|[Yy][Ee][Ss]) sudo reboot ;;
esac
