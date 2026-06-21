if test -x /home/linuxbrew/.linuxbrew/bin/brew
    eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)
end

if status is-interactive
    fish_vi_key_bindings

    if command -v mise &>/dev/null
        mise activate fish | source
    end

    if command -v zoxide &>/dev/null
        zoxide init fish | source

        if not functions -q __original_cd
            functions -c cd __original_cd
        end

        function cd --description 'zoxide-backed cd'
            if test (count $argv) -eq 0
                __original_cd ~; and return
            else if test -d $argv[1]
                __original_cd -- $argv[1]
            else
                z $argv; and printf "\U000F17A9 "; and pwd || echo "Error: Directory not found"
            end
        end
    end

    if command -v starship &>/dev/null
        starship init fish | source
    end

    # Configure fzf.fish keybindings - disable process search
    if command -v fzf &>/dev/null
        fzf_configure_bindings --processes=
    end


    if test -d (brew --prefix)"/share/fish/completions"
        set -p fish_complete_path (brew --prefix)/share/fish/completions
    end

    if test -d (brew --prefix)"/share/fish/vendor_completions.d"
        set -p fish_complete_path (brew --prefix)/share/fish/vendor_completions.d
    end
end

set -g fish_greeting

alias lzd lazydocker
alias lzg lazygit
alias oc opencode
alias open xdg-open
alias vim nvim
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

function mcd
    mkdir -p $argv[1]; and cd $argv[1]
end
