#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "usage: $0 {check|backup} TARGET PACKAGE..." >&2
    exit 2
}

[[ $# -ge 3 ]] || usage

mode="$1"
target="$2"
shift 2

[[ "$mode" == "check" || "$mode" == "backup" ]] || usage

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
target="$(realpath -m "$target")"
declare -a conflicts=()
declare -A seen=()

is_managed_path() {
    local source_path="$1"
    local target_path="$2"

    [[ -e "$target_path" || -L "$target_path" ]] || return 1
    [[ "$(realpath -m "$target_path")" == "$(realpath -m "$source_path")" ]]
}

find_blocking_ancestor() {
    local package_root="$1"
    local relative_path="$2"
    local prefix=""
    local source_path target_path
    local -a parts

    IFS='/' read -ra parts <<< "$relative_path"
    for ((index = 0; index < ${#parts[@]} - 1; index++)); do
        prefix="${prefix:+$prefix/}${parts[$index]}"
        source_path="$package_root/$prefix"
        target_path="$target/$prefix"

        [[ -e "$target_path" || -L "$target_path" ]] || continue
        [[ -d "$target_path" && ! -L "$target_path" ]] && continue
        is_managed_path "$source_path" "$target_path" && continue

        printf '%s\n' "$prefix"
        return 0
    done

    return 1
}

add_conflict() {
    local relative_path="$1"

    if [[ -z "${seen[$relative_path]+x}" ]]; then
        conflicts+=("$relative_path")
        seen["$relative_path"]=1
    fi
}

for package in "$@"; do
    package_root="$repo/$package"
    [[ -d "$package_root" ]] || {
        echo "Unknown stow package: $package" >&2
        exit 2
    }

    while IFS= read -r -d '' source_path; do
        relative_path="${source_path#"$package_root"/}"
        if blocking_path="$(find_blocking_ancestor "$package_root" "$relative_path")"; then
            add_conflict "$blocking_path"
            continue
        fi

        target_path="$target/$relative_path"
        if [[ -e "$target_path" || -L "$target_path" ]] \
            && ! is_managed_path "$source_path" "$target_path"; then
            add_conflict "$relative_path"
        fi
    done < <(find "$package_root" \( -type f -o -type l \) -print0)
done

skills_path="$target/.claude/skills"
skills_target="$target/.agents/skills"
if [[ -e "$skills_path" || -L "$skills_path" ]]; then
    if [[ ! -L "$skills_path" \
        || "$(realpath -m "$skills_path")" != "$(realpath -m "$skills_target")" ]]; then
        add_conflict ".claude/skills"
    fi
fi

if ((${#conflicts[@]} == 0)); then
    echo "No unmanaged conflicts found"
    exit 0
fi

if [[ "$mode" == "check" ]]; then
    echo "Unmanaged paths would be backed up by make:" >&2
    printf '  - %s\n' "${conflicts[@]}" >&2
    exit 1
fi

backup_root="$target/.dotfiles-backups/$(date -u +%Y%m%dT%H%M%SZ)-$$"

for relative_path in "${conflicts[@]}"; do
    source_path="$target/$relative_path"
    backup_path="$backup_root/$relative_path"
    mkdir -p "$(dirname "$backup_path")"
    mv -- "$source_path" "$backup_path"
    printf 'Backed up %s -> %s\n' "$source_path" "$backup_path"
done
