# Disable welcome message
function fish_greeting; end

zoxide init fish --cmd cd | source

# Set personal aliases
alias lzd lazydocker
alias lzg lazygit
alias oc opencode
alias open xdg-open
alias vim nvim
alias zed zeditor

alias docker-disable "sudo systemctl disable docker.service docker.socket; echo \"🚫 Docker disabled at boot\""
alias docker-enable "sudo systemctl enable docker.service docker.socket; echo \"✅ Docker enabled at boot\""
alias docker-down "sudo systemctl stop docker.service docker.socket; echo \"🛑 Docker stopped\""
alias docker-restart "sudo systemctl restart docker.service; echo \"🔁 Docker restarted\""
alias docker-up "sudo systemctl start docker.service docker.socket; echo \"🐳 Docker started\""
alias docker-status "systemctl status docker.service --no-pager"

alias postgres-up "docker run -d --restart unless-stopped -p 127.0.0.1:5432:5432 --name=postgres18 -e POSTGRES_HOST_AUTH_METHOD=trust -v postgres18-data:/var/lib/postgresql postgres:18"
alias psql-local "psql -h localhost -U postgres"
alias redis-up "docker run -d --restart unless-stopped -p 127.0.0.1:6379:6379 --name=redis8 redis:8"

function __edit_cmd
    set cmd $argv[1]
    set editor $argv[2]
    set target (command -v $cmd ^/dev/null)
    or begin
        echo "$editor: command not found: $cmd" >&2
        return 1
    end
    $editor $target
end

complete -c vw -w command
function vw
    __edit_cmd $argv[1] vim
end

complete -c zw -w command
function zw
    __edit_cmd $argv[1] zed
end

alias ls "eza -lh --group-directories-first --icons=auto"

# Set editor
set -gx EDITOR vim

# Starship prompt
starship init fish | source
