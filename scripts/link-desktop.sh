#!/usr/bin/env bash
set -euo pipefail
[[ $# -eq 2 && ( $1 == link || $1 == unlink ) ]] || exit 2
mode=$1
target=$(realpath -m "$2")
repo=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)

# Directory links keep atomic GUI saves inside the checkout. All other
# application configuration retains Stow's existing --no-folding policy.
for relative in .config/niri .config/dms/config.d; do
    source="$repo/home/$relative"
    destination="$target/$relative"
    if [[ $mode == unlink ]]; then
        if [[ -L $destination && $(realpath -m "$destination") == "$source" ]]; then
            rm -- "$destination"
        fi
    elif [[ ! -e $destination && ! -L $destination ]]; then
        mkdir -p "$(dirname "$destination")"
        ln -s "$source" "$destination"
    elif [[ ! -L $destination || $(realpath -m "$destination") != "$source" ]]; then
        echo "Unmanaged desktop directory: $destination; run conflict backup first." >&2
        exit 1
    fi
done
