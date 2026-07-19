#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-$HOME}"
TARGET="$(realpath -m "$TARGET")"
CONFIG="$TARGET/.config/nvim"
REMOTE="https://github.com/nvim-lua/kickstart.nvim.git"
STATE_DIR="$TARGET/.local/state/dotfiles"
READY_MARKER="$STATE_DIR/kickstart-ready"

if [[ ! -e "$CONFIG" ]]; then
    rm -f "$READY_MARKER"
    mkdir -p "$(dirname "$CONFIG")"
    git clone "$REMOTE" "$CONFIG"
elif [[ ! -d "$CONFIG/.git" ]]; then
    echo "nvim config already exists, skipping Kickstart setup"
    exit 0
fi

origin="$(git -C "$CONFIG" remote get-url origin 2>/dev/null || true)"
if [[ "$origin" != "$REMOTE" ]]; then
    echo "nvim config is not Kickstart.nvim, skipping setup"
    exit 0
fi

if [[ -f "$READY_MARKER" ]]; then
    echo "Kickstart.nvim is ready"
    exit 0
fi

HOME="$TARGET" XDG_CONFIG_HOME="$TARGET/.config" nvim --headless '+qa'
mkdir -p "$STATE_DIR"
touch "$READY_MARKER"
echo "Kickstart.nvim is ready"
