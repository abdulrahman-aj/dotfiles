#!/usr/bin/env bash
set -euo pipefail

[[ -f /etc/arch-release ]] || exit 0
target="$(realpath -m "${1:-$HOME}")"
[[ "$target" == "$(realpath -m "$HOME")" ]] || exit 0
command -v yay >/dev/null || { echo 'Missing required command: yay' >&2; exit 1; }

if command -v omarchy >/dev/null; then
    [[ -f "$HOME/.local/state/omarchy/preinstalls-removed" ]] || omarchy remove preinstalls
    install_packages=(omarchy pkg add)
else
    install_packages=(sudo pacman -Syu --needed --noconfirm)
fi

"${install_packages[@]}" alacritty neovim python fish stow git curl github-cli git-delta \
    starship zoxide eza fzf fd bat lazygit jq ttf-jetbrains-mono-nerd zed mise \
    nodejs npm nix worktrunk dosfstools ntfs-3g usb_modeswitch
sudo systemctl enable --now nix-daemon.socket

if command -v omarchy >/dev/null; then
    omarchy pkg add t3code-bin omarchy-fish omazed
    omazed setup
    # Browser setup also applies Omarchy's policies and Wayland settings.
    omarchy install browser chrome
    omarchy install browser zen
    omarchy default browser zen
    if ! omarchy plugin list 2>/dev/null | grep -q 'aj.opencode-go'; then
        omarchy plugin add git@github.com:abdulrahman-aj/omarchy-opencode-go.git --enable --yes
    fi
else
    yay -S --needed google-chrome zen-browser-bin t3code-bin
fi

mise use -g herdr codex npm:hunkdiff
if [[ -z "$(mise ls -g -i --no-header 'npm:@opencode/cli')" ]]; then
    mise use -g --tool-option 'allow_builds=["@opencode/cli"]' \
        --tool-option 'allow_low_downloads=true' 'npm:@opencode/cli@latest'
fi
if [[ "$(getent passwd "$USER" | cut -d: -f7)" != "$(command -v fish)" ]]; then
    chsh -s "$(command -v fish)" "$USER"
fi
