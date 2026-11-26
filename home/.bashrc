# The login shell is bash, so scripts and ssh commands run in bash, and
# `tailscale ssh` one-shots (run through `su -l`) also get the login PATH from
# /etc/profile.d. Interactive terminals hand over to fish.
[[ $- != *i* ]] && return

# Hand over only a plain interactive shell on a terminal: not `bash -ic cmd`,
# not `bash -i script` ($0 is then the script), not `bash -i -s` reading a
# pipe, and not `bash` typed inside fish.
if [[ ! -v BASH_EXECUTION_STRING && ($0 == bash || $0 == -bash || $0 == "$BASH") && -t 0 ]] &&
    [[ $(</proc/$PPID/comm) != fish ]] && command -v fish >/dev/null; then
    shopt -q login_shell && exec fish --login
    exec fish
fi

# Interactive bash that stays bash: `bash` typed in fish, and IDEs that read the
# environment with `$SHELL -i -l -c env`. mise puts its tools on PATH, as
# config.fish does for fish.
command -v mise >/dev/null && eval "$(mise activate bash)"
