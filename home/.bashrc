# PATH and EDITOR come from arch-niri-dux's /etc/profile.d, which login shells read.
# Scripts and one-shot ssh commands need nothing below.
[[ $- != *i* ]] && return

# ble.sh gives fish-style autosuggestions and syntax highlighting. It loads
# first and attaches last, after everything that changes the prompt or bindings.
# Without ~/.cache it falls back to a cache next to itself, in the read-only
# store, and fails to load.
blesh="$HOME/.nix-profile/share/blesh/ble.sh"
[[ -r $blesh ]] && mkdir -p "${XDG_CACHE_HOME:-$HOME/.cache}" && source "$blesh" --noattach
unset blesh

set -o vi
shopt -s histappend
HISTCONTROL=ignoreboth
HISTSIZE=32768
HISTFILESIZE=$HISTSIZE

# mise switches tool versions under the same command names; a hashed path
# would keep running the old version.
set +h
command -v mise >/dev/null && eval "$(mise activate bash)"

# Loads each command's completion on its first Tab, including the ones in
# ~/.local/share/bash-completion/completions.
[[ -r /usr/share/bash-completion/bash_completion ]] && source /usr/share/bash-completion/bash_completion

if command -v zoxide >/dev/null; then
    eval "$(zoxide init bash)"
    cd() {
        if (($# == 0)); then
            builtin cd ~
        elif [[ -d $1 ]]; then
            builtin cd -- "$1"
        else
            z "$@" && printf '\U000F17A9 ' && pwd || echo "Error: Directory not found"
        fi
    }
fi

command -v starship >/dev/null && eval "$(starship init bash)"
command -v wt >/dev/null && eval "$(wt config shell init bash)"

# Ctrl-R history, Ctrl-T files, Alt-C directories. ble.sh needs its own
# wrapper of fzf's bindings; plain bash takes them directly.
if command -v fzf >/dev/null; then
    if [[ ${BLE_VERSION-} ]]; then
        ble-import -d integration/fzf-key-bindings
    else
        source /usr/share/fzf/key-bindings.bash
    fi
fi

if command -v eza >/dev/null; then
    alias ls='eza -lh --group-directories-first --icons=auto'
    alias lt='eza --tree --level=2 --long --icons --git'
fi
alias grep='grep --color=auto'
alias ...='cd ../..'
alias ....='cd ../../..'
alias lzg=lazygit
alias oc=opencode
alias open=xdg-open
alias vim=nvim
alias postgres-up='docker run -d --restart unless-stopped -p 127.0.0.1:5432:5432 --name=postgres18 -e POSTGRES_HOST_AUTH_METHOD=trust -v postgres18-data:/var/lib/postgresql postgres:18'
alias psql-local='psql -h localhost -U postgres'
alias redis-up='docker run -d --restart unless-stopped -p 127.0.0.1:6379:6379 --name=redis8 redis:8'

# Open a command's script in an editor: `vw heavy`.
_edit_cmd() {
    local target
    target=$(type -P "$1") || { echo "$2: command not found: $1" >&2; return 1; }
    "$2" "$target"
}
vw() { _edit_cmd "$1" nvim; }
zw() { _edit_cmd "$1" zed; }
complete -c vw zw

mcd() { mkdir -p -- "$1" && cd -- "$1"; }

[[ ${BLE_VERSION-} ]] && ble-attach
