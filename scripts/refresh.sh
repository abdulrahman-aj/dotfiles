#!/usr/bin/env bash
# Fast-forward the dotfiles and agent-config checkouts; make refresh redeploys.
set -euo pipefail

usage() {
    echo "usage: $0 DOTFILES_DIR AGENT_CONFIG_DIR" >&2
    exit 2
}

[[ $# -eq 2 ]] || usage

# Only fast-forward a clean main: anything else is work in progress, and
# deploying stays live off whatever the checkout holds.
fast_forward() {
    local repo="$1"
    local branch

    if ! git -C "$repo" rev-parse --git-dir >/dev/null 2>&1; then
        echo "Skipping $repo: not a git checkout"
        return
    fi
    branch="$(git -C "$repo" branch --show-current)"
    if [[ "$branch" != main ]]; then
        echo "Skipping $repo: on '${branch:-detached HEAD}', not main"
        return
    fi
    if [[ -n "$(git -C "$repo" status --porcelain)" ]]; then
        echo "Skipping $repo: uncommitted changes"
        return
    fi
    git -C "$repo" pull --ff-only --quiet origin main 2>/dev/null \
        || echo "Skipping $repo: cannot fast-forward to origin/main"
}

fast_forward "$1"
fast_forward "$2"
