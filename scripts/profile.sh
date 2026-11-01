#!/usr/bin/env bash
set -euo pipefail
profile="${PROFILE:-auto}"
if [[ "$profile" == auto ]]; then
    profile=full
    if [[ "$(uname -s)" == Linux && -r /etc/os-release ]]; then
        os_id="$(set +u; source /etc/os-release; printf '%s' "${ID:-}")"
        [[ "$os_id" != arch ]] || profile=arch
    fi
fi
case "$profile" in arch|full) echo "$profile" ;; *) echo "Unknown profile: $profile" >&2; exit 1 ;; esac
