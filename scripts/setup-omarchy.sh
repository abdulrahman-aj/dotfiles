#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname -s)" != "Linux" ]]; then
    exit 0
fi

target="${1:-$HOME}"
if [[ "$(realpath -m "$target")" != "$(realpath -m "$HOME")" ]]; then
    exit 0
fi

os_id=""
if [[ -r /etc/os-release ]]; then
    os_id="$(set +u; source /etc/os-release; printf '%s' "${ID:-}")"
fi

if [[ "$os_id" != "omarchy" ]] || ! command -v omarchy >/dev/null 2>&1; then
    exit 0
fi

if [[ ! -f "$HOME/.local/state/omarchy/preinstalls-removed" ]]; then
    omarchy remove preinstalls
fi

omarchy pkg add alacritty dosfstools fish git-delta github-cli ntfs-3g starship stow \
    || echo "Warning: some Omarchy packages could not be installed; continuing." >&2
omarchy pkg add opencode \
    || echo "Warning: OpenCode could not be installed; continuing." >&2
omarchy pkg aur add google-chrome \
    || echo "Warning: Chrome could not be installed; continuing." >&2

if ! command -v zeditor >/dev/null 2>&1 || ! command -v omazed >/dev/null 2>&1; then
    omarchy install editor zed \
        || echo "Warning: Zed or its Omarchy integration could not be installed; continuing." >&2
fi
