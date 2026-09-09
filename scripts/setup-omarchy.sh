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

omarchy pkg add alacritty fish git-delta github-cli starship stow worktrunk
omarchy pkg add omarchy-fish
omarchy pkg add opencode
omarchy pkg aur add google-chrome
omarchy install browser zen
omarchy default browser zen
omarchy install editor zed

# Filesystem drivers for external drives.
omarchy pkg add dosfstools ntfs-3g

# Ensure mode-switching Wi-Fi adapters initialize as network devices.
omarchy pkg add usb_modeswitch

if ! omarchy plugin list 2>/dev/null | grep -q "aj.opencode-go"; then
    omarchy plugin add git@github.com:abdulrahman-aj/omarchy-opencode-go.git --enable --yes
fi

# Mise-managed dev tools.
mise use -g npm:hunkdiff

if [[ "$(getent passwd "$USER" | cut -d: -f7)" != "$(command -v fish)" ]]; then
    chsh -s "$(command -v fish)" "$USER"
fi
