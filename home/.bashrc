# The login shell is bash, so ssh one-shots, agents and scripts get bash and
# the login PATH from /etc/profile.d. Interactive terminals hand over to fish.
# Typing `bash` inside fish stays in bash, because its parent is fish.
[[ $- != *i* ]] && return

if [[ -z ${BASH_EXECUTION_STRING-} && $(</proc/$PPID/comm) != fish ]] && command -v fish >/dev/null; then
    shopt -q login_shell && exec fish --login
    exec fish
fi
