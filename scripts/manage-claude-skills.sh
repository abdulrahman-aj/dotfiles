#!/usr/bin/env bash
set -euo pipefail

[[ $# -eq 2 ]] || {
    echo "usage: $0 {link|unlink} TARGET" >&2
    exit 2
}

mode="$1"
target="$(realpath -m "$2")"
link_path="$target/.claude/skills"
link_target="$target/.agents/skills"

case "$mode" in
    link)
        mkdir -p "$target/.claude"
        ln -sfn "$link_target" "$link_path"
        ;;
    unlink)
        if [[ -L "$link_path" \
            && "$(realpath -m "$link_path")" == "$(realpath -m "$link_target")" ]]; then
            rm -- "$link_path"
        fi
        ;;
    *)
        echo "usage: $0 {link|unlink} TARGET" >&2
        exit 2
        ;;
esac
