#!/usr/bin/env bash
# Enable the stowed systemd user units. Runs after stow, which links them.
set -euo pipefail

[[ -f /etc/arch-release ]] || exit 0
target="$(realpath -m "${1:-$HOME}")"
[[ "$target" == "$(realpath -m "$HOME")" ]] || exit 0

# Without a user session bus (e.g. over plain SSH), warn instead of aborting setup.
if ! systemctl --user daemon-reload \
    || ! systemctl --user enable --now mise-upgrade.timer; then
    echo 'Could not enable mise-upgrade.timer; rerun make from a desktop session.' >&2
fi
