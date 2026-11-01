#!/usr/bin/env bash
set -euo pipefail

target="$(realpath -m "${1:-$HOME}")"
[[ "$target" == "$(realpath -m "$HOME")" ]] || exit 0

# The offline installation supplies yay and its build prerequisites.
for command_name in yay sudo; do
    command -v "$command_name" >/dev/null 2>&1 || {
        echo "Missing required command: $command_name" >&2
        exit 1
    }
done

sudo pacman -S --needed --noconfirm fish stow github-cli git-delta starship \
    zoxide eza fzf fd bat lazygit jq ttf-jetbrains-mono-nerd zed mise nodejs npm dosfstools ntfs-3g usb_modeswitch
# Yay resolves both repository and AUR packages, and --needed makes retries safe.
yay -S --needed worktrunk google-chrome zen-browser-bin t3code-bin
mise use -g herdr
mise use -g codex
mise use -g npm:hunkdiff
if [[ -z "$(mise ls -g -i --no-header 'npm:@opencode/cli')" ]]; then
    mise use -g --tool-option 'allow_builds=["@opencode/cli"]' \
        --tool-option 'allow_low_downloads=true' 'npm:@opencode/cli@latest'
fi
if [[ "$(getent passwd "$USER" | cut -d: -f7)" != "$(command -v fish)" ]]; then
    chsh -s "$(command -v fish)" "$USER"
fi
