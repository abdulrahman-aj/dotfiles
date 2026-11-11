#!/usr/bin/env bash
# Clone github.com/abdulrahman-aj/dux-ai-usage and link it as a Dux plugin.
# Never replaces a real directory at the link path; only a symlink.
set -euo pipefail

target="$(realpath -m "${1:-$HOME}")"
clone_dir="$(realpath -m "${DUX_AI_USAGE_DIR:-"$target/dux-ai-usage"}")"
repo="${DUX_AI_USAGE_REPO:-https://github.com/abdulrahman-aj/dux-ai-usage.git}"
link_path="$target/.config/dms/plugins/DuxAiUsage"

if [[ ! -e "$clone_dir" ]]; then
    gh repo clone "$repo" "$clone_dir"
fi

mkdir -p "$target/.config/dms/plugins"
if [[ -e "$link_path" && ! -L "$link_path" ]]; then
    echo "Refusing to replace $link_path: not a symlink" >&2
    exit 1
fi
ln -sfn "$clone_dir/DuxAiUsage" "$link_path"

if [[ "$target" == "$(realpath -m "$HOME")" ]] && command -v dms >/dev/null 2>&1; then
    dms ipc call plugins enable duxAiUsage \
        || echo "Dux is not running; enable later with: dms ipc call plugins enable duxAiUsage"
else
    echo "Skipping plugin enable for $target; enable with: dms ipc call plugins enable duxAiUsage"
fi
