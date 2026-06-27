#!/usr/bin/env bash
set -euo pipefail

CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
REMOTE="https://github.com/nvim-lua/kickstart.nvim.git"

if [[ -d "$CONFIG" ]]; then
    echo "nvim config already exists, skipping Kickstart setup"
    exit 0
fi

git clone "$REMOTE" "$CONFIG"
nvim --headless '+qa'
echo "Kickstart.nvim installed"
