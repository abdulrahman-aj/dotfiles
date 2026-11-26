#!/usr/bin/env bash
set -euo pipefail

[[ -f /etc/arch-release ]] || exit 0
target="$(realpath -m "${1:-$HOME}")"
[[ "$target" == "$(realpath -m "$HOME")" ]] || exit 0

sudo pacman -Syu --needed --noconfirm \
    alacritty neovim python bash-completion stow git curl github-cli git-delta \
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

mise use -g claude herdr codex agy npm:hunkdiff opencode

# The user nix.conf that enables flakes isn't stowed yet on a first run.
nix --extra-experimental-features 'nix-command flakes' profile add nixpkgs#blesh

if [[ "$(getent passwd "$USER" | cut -d: -f7)" != /bin/bash ]]; then
    chsh -s /bin/bash "$USER"
fi
