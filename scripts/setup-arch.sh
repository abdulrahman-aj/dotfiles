#!/usr/bin/env bash
set -euo pipefail

[[ -f /etc/arch-release ]] || exit 0
target="$(realpath -m "${1:-$HOME}")"
[[ "$target" == "$(realpath -m "$HOME")" ]] || exit 0

sudo pacman -Syu --needed --noconfirm \
    alacritty neovim python fish stow git curl github-cli git-delta \
    starship zoxide eza fzf fd bat tldr lazygit jq ttf-jetbrains-mono-nerd zed mise \
    nodejs npm nix worktrunk dosfstools ntfs-3g usb_modeswitch \
    google-chrome zen-browser-bin t3code-bin tailscale
sudo systemctl enable --now nix-daemon.service nix-daemon.socket

if tailscale status &>/dev/null; then
    echo "Tailscale already connected"
elif [[ -t 0 ]]; then
    read -r -p "Set up Tailscale now? [Y/n] " reply
    case "${reply:-Y}" in
    [Yy]*)
        sudo systemctl enable --now tailscaled.service
        sudo tailscale up || echo \
            "Tailscale login skipped; run 'sudo tailscale up' to log in."
        sudo tailscale set --operator="$USER"
        ;;
    *) echo "Skipping Tailscale setup." ;;
    esac
fi

mise use -g herdr codex npm:hunkdiff
if [[ -z "$(mise ls -g -i --no-header 'npm:@opencode/cli')" ]]; then
    mise use -g --tool-option 'allow_builds=["@opencode/cli"]' \
        --tool-option 'allow_low_downloads=true' 'npm:@opencode/cli@latest'
fi
if [[ "$(getent passwd "$USER" | cut -d: -f7)" != "$(command -v fish)" ]]; then
    chsh -s "$(command -v fish)" "$USER"
fi
