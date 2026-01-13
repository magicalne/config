## Aliases migrated from zsh config

# System aliases
alias sudo='sudo '
alias vim='nvim'

# Use exa if available, otherwise fallback to ls
if command -q exa
    alias ls='exa'
    alias ll='exa -l'
    alias la='exa -la'
    alias lt='exa -T'
else
    alias ll='ls -la'
end

# Docker/Podman aliases
# Uncomment if you use podman instead of docker
# alias docker='podman'

# CDK alias with bunx
alias cdk='bunx cdk'

# Clipboard aliases (Linux)
# Uncomment for xclip clipboard support
# alias pbcopy='xclip -selection clipboard'
# alias pbpaste='xclip -selection clipboard -o'

# ========== Additional useful fish aliases ==========

# Navigation improvements
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Git shortcuts (if you use git)
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
alias ports='netstat -tulpn'

# ========== Functions (better than aliases for complex commands) ==========

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
