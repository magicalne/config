## Shared aliases for macOS and Linux

# System aliases
alias sudo='sudo '
alias vim='nvim'

# Prefer eza if available, but keep exa-compatible muscle memory.
if command -q eza
    alias exa='eza'
end

if command -q exa
    alias ls='exa'
    alias ll='exa -l'
    alias la='exa -la'
    alias lt='exa -T'
else
    alias ll='ls -la'
end

# Docker / Podman
# Uncomment if you want docker -> podman by default.
# alias docker='podman'

# CDK via bunx
alias cdk='bunx cdk'

# Clipboard helpers on Linux
if test (uname) = Linux
    if command -q xclip
        alias pbcopy='xclip -selection clipboard'
        alias pbpaste='xclip -selection clipboard -o'
    end
end

# Navigation improvements
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Git shortcuts
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gcm='git commit -m'
alias gco='git checkout'
alias gp='git push'
alias gpl='git pull'
alias gl='git log --oneline --graph'

# Safety aliases
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Quick edits
alias fishconfig='nvim ~/.config/fish/config.fish'
alias aliases='nvim ~/.config/fish/alias.fish'
alias envs='nvim ~/.config/fish/env.fish'

# System monitoring
alias pstop='top -o cpu'
alias mstop='top -o rsize'
alias df='df -h'
alias du='du -h'

# Network
alias myip='curl ifconfig.me'

function ports --description 'List listening ports'
    switch (uname)
        case Darwin
            lsof -nP -iTCP -sTCP:LISTEN
        case Linux
            if command -q ss
                ss -tulpn
            else if command -q netstat
                netstat -tulpn
            else
                echo 'No supported port listing command found'
            end
    end
end

# Create directory and cd into it
function mkcd --description 'Create directory and cd into it'
    mkdir -p $argv[1]
    cd $argv[1]
end

# Extract various archive types
function extract --description 'Extract various archive types'
    if test -f $argv[1]
        switch $argv[1]
            case *.tar.bz2
                tar xjf $argv[1]
            case *.tar.gz
                tar xzf $argv[1]
            case *.bz2
                bunzip2 $argv[1]
            case *.rar
                unrar x $argv[1]
            case *.gz
                gunzip $argv[1]
            case *.tar
                tar xf $argv[1]
            case *.tbz2
                tar xjf $argv[1]
            case *.tgz
                tar xzf $argv[1]
            case *.zip
                unzip $argv[1]
            case *.Z
                uncompress $argv[1]
            case *.7z
                7z x $argv[1]
            case '*'
                echo "'$argv[1]' cannot be extracted via extract"
        end
    else
        echo "'$argv[1]' is not a valid file"
    end
end

# Quick cheat sheets
function cheat --description 'Show cheat sheet for command'
    curl cheat.sh/$argv[1]
end
